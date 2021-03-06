require 'spec_helper'

describe User do
  before { @user = User.new(name: "Karol", email: "karol@gmail.com",
                            password: "foobar", password_confirmation: "foobar") }
  
  subject { @user }
  
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) } 
  it { should respond_to(:follow!) }
  
  it { should be_valid } # sanity check
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end
  
  describe "when name is not present" do
    before { @user.name = "" }
    it { should_not be_valid }
  end
  
  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end
  
  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end
  
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end
  
  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end
  
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    
    it { should_not be_valid }
  end
  
  describe "when password not present" do
    before do
      @user = User.new(name: "Foo Bar", email: "foo@bar.com", password: " ", password_confirmation: " " )
    end
    it { should_not be_valid }
  end
  
  describe "when password mismatch" do
    before do
      @user.password_confirmation = "mismatch"
    end
    it { should_not be_valid }
  end
  
  describe "with a password that's too short" do
    before do
      @user.password = @user.password_confirmation = "a" * 5
    end
    
    it { should be_invalid }
    
  end
  
  describe "return value of authenticate method" do
    before do
      @user.save
    end
    
    let (:found_user) { User.find_by(email: @user.email) }
    
    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end
    
    describe "with invalid password" do
      let (:user_for_invalid_password) { found_user.authenticate("wrong password") }
      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end
  
  describe "email address with mixed case" do
    let(:mixed_email) { "fOO@BaR.com" }
    
    it "should be downcasted after save" do
      @user.email = mixed_email
      @user.save
      expect(@user.reload.email).to eq mixed_email.downcase
    end
  end

  describe "remember token" do
    before { @user.save }
    its (:remember_token) {should_not be_blank}
  end
  
  describe "micropost associations" do
    before { @user.save }
    
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end
    
    it "should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end
    
    it "should destroy associated microposts" do
      # Need to call to_a to create copy of microposts. Otherwise @user.microposts is empty once we call @user.destroy
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      # Make sure user's microposts are no longer in the database after deleting the user
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end
    
    describe "status" do
      let!(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      
      let!(:followed_user) { FactoryGirl.create(:user) } 
      
      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end
      
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end # end micropost associations
  
  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) } 
    before do
      @user.save
      @user.follow!(other_user)
    end
    
    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }
    
    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }
      
      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
    
    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end
    
    describe "relationship association" do
      before do
        ## its(:followers) { should include(other_user) } # fail - undefined method its
        other_user.destroy
      end
      ## other_user.destroy # fail - undefined local variable or method other_user (need to access from before/it/specify block)
      
      it "deletes associatesd relationship" do
        expect(@user.followers).not_to include(other_user) 
      end
      
      it "has correct name" do
        expect(@user.name).to eq("Karol")
      end
      
      its(:followers) { should_not include(other_user) }
      
    end
   
  end # end following
  
  describe "My learning demos" do
    describe Array do
      describe "with 3 items" do
        before { @arr = [1, 2, 3] }
    
        specify { @arr.should_not be_empty }
        specify { @arr.count.should eq(3) }
      end
    end
    
    describe "My Demo" do
      describe "array with 3 items" do
        subject { [1, 2, 3] }
    
        it { should_not be_empty }
        its(:count) { should eq(3) }
      end
      
      describe "demo different constructs" do
        before { @a = 4 }
        let(:b) { 5 }
        
        # specify (sysnonym for it) for single line
        specify { @a.should eq(4) } # use of should (not recommended - better expect instead)
        
        it do
          @a = 5
          expect(@a).to eq(5)
          # even though we changed value of @a, in next specify/it it will have the old value 
          # cause before is by default before :each and will be run before every example (it/specify)
          # and therefore b will be set to 5 before every example
        end
        
        # specify (synonym for it) for multiple lines
        specify do
          expect(@a).not_to eq(5) # use of expect (recommended)
          expect(b).to eq(5)
          expect(@a).not_to eq(b)
        end
        
        # it for single line
        it { expect(@a).to eq(4) }
        
        # it for multiple lines
        it do
          expect(@a).not_to eq(5)
          expect(b).to eq(5)
        end
        
      end # end demo different constructs
    end # end demo
  end # end my demos
end

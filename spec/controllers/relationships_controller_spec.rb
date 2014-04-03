require 'spec_helper'

describe RelationshipsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  
  before { sign_in user, no_capybara: true} 
  
  describe "Creating relationship with Ajax" do
    it "should increment relationships count" do
      expect do
        xhr :post, :create, relationship: { followed_id: other_user.id }
      end.to change(Relationship, :count).by(1)
    end
    
    it "should respond with success" do
      xhr :post, :create, relationship: { followed_id: other_user.id }
      expect(response).to be_success
    end
  end  
  
  describe "Destroying relationship with Ajax" do
    before { user.follow!(other_user) }
    let(:relationship) { Relationship.find_by(followed_id: other_user.id) }
    
    it "should decrement relationship count" do
      expect do
        xhr :delete, :destroy, id: relationship.id
      end.to change(Relationship, :count).by(-1)
    end
    
    it "should respond with succcess" do
      xhr :delete, :destroy, id:relationship.id
      expect(response).to be_success
    end
  end
  
end

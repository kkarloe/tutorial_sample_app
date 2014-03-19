require 'spec_helper'

# TODO: Doesn't work (passes even if I didn't have logic to restrict admin to delete himself implemented)
describe UsersController do

	# Test below doesn't belong here (controller spec shouldn't test UI in web browser). 
	# It's added just as proof of concept that capybara and subject {page} work in controller spec
	describe "capybara test" do
	subject {page}
		before do 
			visit signin_path
			click_button "Sign in"
		end	
		it { should have_content 'Email/password don\'t match' }

	end
  describe "admins-userscontroller" do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:non_admin) { FactoryGirl.create(:user) }
	

    it "should not be able to delete themself" do
      sign_in admin, no_capybara: true
      expect { delete :destroy, :id => admin.id }.not_to change(User, :count)
    end
  end
end
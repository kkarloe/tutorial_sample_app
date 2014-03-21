require 'spec_helper'
require 'pp'

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
    let(:admin) { FactoryGirl.create(:admin) } # no need to use let! cause admin will be evaluated (and crated) during sign_in process
    let!(:non_admin) { FactoryGirl.create(:user) } # use let! instead of let cause let is lazy evaluated and non_admin wouldn't be created until it's used...
	

    it "should not be able to delete themself" do
      sign_in admin, no_capybara: true
      
      # pp outputs admin straight to the console from which we run tests
      #pp admin 
      #pp "I can output custom text to the console. This text doesn't gets saved in the log file"
      
      # Another way to output to the console:
      #puts admin.to_yaml

      # Rails.logger outputs to the file
      #Rails.logger.debug "Log message"
      Rails.logger.tagged("RSPEC") { Rails.logger.debug "Destroying admin user with id: #{admin.id} " }
      expect { delete :destroy, :id => admin.id }.not_to change(User, :count)
    end
  end
end
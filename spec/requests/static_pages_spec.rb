require 'spec_helper'

describe "Static pages" do
  
  let(:base_title) {"Ruby on Rails Tutorial Sample App"}
  
  subject { page }
  
  shared_examples_for "all static pages" do
    it { should have_selector("h1", text: heading)}
    it { should have_title(full_title(page_title)) }  
  end
  
  describe "Home page" do
    before { visit root_path }
    
    it { should have_content('Sample App') }
    it { should have_title(full_title('')) }
    it { should_not have_title("#{base_title} | Home") }
    
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end
      
      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end
    end
  end
  
  describe "Help page" do
    before { visit help_path }
    
    it { should have_content('Help') }
    it { should have_title(full_title("Help")) }
  end
  
  describe "About page" do
    before { visit about_path }
    
    it { should have_content('About Us') }     
    it { should have_title(full_title("About")) }
  end   
  
  describe "Contact page" do
    before { visit contact_path }
    
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }
    it_should_behave_like "all static pages"
  end
  
  describe "Static pages" do
    it "should have correct links on the layout" do
      visit root_path
      click_link 'About'
      expect(page).to have_title(full_title('About'))
      click_link 'Help'
      expect(page).to have_title(full_title('Help'))
      # Similar tests should be for other links
    end
  end
end


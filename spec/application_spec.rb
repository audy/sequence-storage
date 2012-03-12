require File.join(File.dirname(__FILE__), 'spec_helper')

  describe 'The homepage' do

  it 'should load the index page successfully' do
    get '/'
    last_response.should be_ok
  end

  it 'should have a link to login' do
    get '/'
    response_body.should contain 'Login'
  end
end

describe 'User pages' do
  
  let (:user) { User.create :name => "test_user", :email => "test@test.com", :password => 'test' }
  
  let (:login!) {
    visit '/session/new'
    fill_in 'email', :with => user.email
    fill_in 'password', :with => user.password
    click_button "Login"
  }
  
  it 'should list users' do
    login!
    visit '/users'
    response_body.should contain user.name
  end

  it 'should display user information' do
    login!
    visit '/user/1'
    response_body.should contain user.name
  end

  it 'should not display user information when not logged in' do
    visit '/user/1'
    response_body.should_not contain user.name
  end
end

describe 'Experiment pages' do

  let (:user) { User.create :name => "test_user", :email => "test@test.com", :password => 'test' }

  let (:login!) {
    visit '/session/new'
    fill_in 'email', :with => user.email
    fill_in 'password', :with => user.password
    click_button "Login"
  }

  let (:experiment){Experiment.create :name => "test_experiment", :description => "test_description"}

  it 'should list experiments' do
    login!
    experiment.users << user
    experiment.save
    visit '/experiments'
    response_body.should contain experiment.name
  end

  it 'should be able to login' do
    login!
    visit '/experiments'
    response_body.should contain "Logout"
  end

  it 'should not create experiments without name' do
    login!
    visit '/experiment/new'
    fill_in 'description', :with => "This experiment should not be created"
    click_button "Save"
    response_body.should_not contain experiment.name
  end

  it 'should create experiment', :broken => true do
   login!
   visit '/experiment/new'
   fill_in 'name', :with => "test_experiment"
   fill_in 'description', :with => "This experiment should be created"
   click_button "Save"
   response_body.should contain "test_experiment"
  end
end
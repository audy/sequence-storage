require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'The homepage' do

  it 'should load the index page successfully' do
    get '/'
    last_response.should be_ok
  end
  
  it 'should have a link to login' do
    get '/'
    response_body.should contain 'login'
  end
  
  it 'should have a link to join' do
    get '/'
    response_body.should contain 'join'
  end
end

describe '/users' do
  let (:user) { User.create :name => "test_user", :email => "test@test.com", :password => 'test' }

  it 'should list users' do
    user
    get '/users'
    response_body.should contain user.name
  end
end
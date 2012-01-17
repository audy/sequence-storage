require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'The homepage' do
  
  def app
    Sinatra::Application
  end

  it 'should load the index page successfully' do
    get '/'
    last_response.should be_ok
  end
  
  it 'should have a link to list experiments' do
    get '/'
    response_body.should contain 'Experiments'
  end
  
  it 'should have a link to list users' do
    get '/'
    response_body.should contain 'Users'
  end
end

describe '/users' do
  let (:user) { User.create :name => "test_user", :email => "test@test.com", :password => 'test' }

  def app
    Sinatra::Application
  end

  
  it 'should list users' do
    user
    get '/users'
    response_body.should contain user.name
  end
end
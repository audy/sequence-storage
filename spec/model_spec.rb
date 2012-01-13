require File.join(File.dirname(__FILE__), 'spec_helper')

# Experiment Model
#
describe 'Experiment Model' do
  
  let(:experiment) { Experiment.new(:name => 'test') }
  
  it 'should be created' do
    experiment.should_not be_nil
  end
  
  it 'can be saved' do
    experiment.save
    experiment.id.should_not be_nil
  end
  
  it 'can have a description' do
    experiment.description = "blah blah blah"
    experiment.description.should_not be_nil
  end
  
  it 'is invalid without a name' do
    experiment.name = nil
    experiment.valid?.should be_false
  end
  
end

describe 'User Model' do
  
  let(:user) { User.new(:email => 'test@test.com', :name => 'Testy McTesterson') }
  
  it 'can be created' do
    user.should_not be_nil
  end
  
  it 'has a name' do
    user.name.should_not be_nil
  end
  
  it 'has an email' do
    user.email.should_not be_nil
  end
  
  it 'encrypts password' do
    user.password = 'test_password'
    user.save
    user.crypted_password.should_not be_nil
  end
  
  it 'can be authenticated' do
    user.password = 'test_password'
    user.save
    user = User.authenticate('test@test.com', 'test_password')
    user.should_not be_nil
  end
  
  it 'can reject bad authentication' do
    user.password = 'test_password'
    user.save
    user = User.authenticate('test@user.com', 'this is not the password')
    user.should be_nil
  end
  
end
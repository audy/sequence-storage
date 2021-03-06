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
  
  it 'can be saved' do
    experiment.save.should_not be_false
  end
  
  it 'can have a description' do
    experiment.description = "blah blah blah"
    experiment.description.should_not be_nil
  end
  
  it 'is invalid without a name' do
    experiment.name = nil
    experiment.valid?.should be_false
  end
  
  it 'can be given owner' do
    user = User.new(:email => 'test@test.com', :name => 'Testy McTesterson')
    experiment.users << user
    experiment.save.should_not be_false
  end
  
  it 'can be given owners' do
    user = User.new(:email => 'test@test.com', :name => 'Testy McTesterson')
    user = User.new(:email => 'test2@test2.com', :name => 'Bill Gates')
    user = User.new(:email => 'test3@test3.com', :name => 'Testy McTesterson III')
    experiment.users << user
    experiment.save.should_not be_false
  end
end

describe 'User Model' do
  
  let(:user) {
    User.new(
      :email => 'test@test.com',
      :name => 'Testy McTesterson'
    )
  }
  
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
  
  it 'can be given experiments' do
    user.experiments << Experiment.new(:name => 'test')
    user.save.should_not be_false
    user.experiments.should_not be_nil
  end
  
  it 'should update' do
    user.save
    user.update(:name => 'updated name')
  end
  
end

describe 'Dataset' do

  let (:experiment) {
    Experiment.create(
      :name => 'test experiment',
    )
  }
  
  let(:user) {
    User.create(
      :email => 'test@test.com',
      :name => 'Testy McTesterson',
      :password => 'asdf'
      )
  }

  let(:dataset) {
    Dataset.create(
      :size => 1000,
      :path => '/dir1/dir2/',
      :mdsum => 'okok',
      :user => user,
      :experiment => experiment,
      :last_modified => DateTime.now,
    )
  }
  
  it 'can be created' do
    dataset.should_not be_nil
  end
  
  it 'can be saved' do
    dataset.save.should_not be_false
  end
  
  it 'has a name' do
    dataset.name.should_not be_nil
  end
  
  it 'has a size' do
    dataset.size.should_not be_nil
  end
  
  it 'has a create time' do
    dataset.created_at.should_not be_nil
  end
  
  it 'has a modified time' do
    dataset.last_modified.should_not be_nil
  end
  
  it 'has a path' do
    dataset.path.should_not be_nil
  end
  
  it 'has a mdsum' do
    dataset.mdsum.should_not be_nil
  end
  
  it 'can be given experiment' do
    dataset.experiment = Experiment.new(:name => 'test')
    dataset.save.should_not be_false
    dataset.experiment.should_not be_nil
  end  
  
  it 'can be given experiments, will overwrite the old ones' do
    dataset.experiment = Experiment.new(:name => 'old1')
    dataset.experiment = Experiment.new(:name => 'old2')
    dataset.experiment = Experiment.new(:name => 'current')
    dataset.save.should_not be_false
    dataset.experiment.name.should_not == "old1"
    dataset.experiment.name.should_not == "old2"
    dataset.experiment.name.should == "current"
  end
  
  it 'can be updated' do
    dataset.update(:path => '1111')
    dataset.path.should == '1111'
  end
  
end

describe 'Sharelink Model' do
  
  let(:sharelink) { Sharelink.new }
  
  let (:experiment) { Experiment.new(:name => 'test') }
  
  let (:dataset) { Dataset.new(
    :size => 1000,
    :path => '/dir1/dir2/',
    :mdsum => 'okok',
    :user => user,
    :experiment => experiment,
  )}
  
  let(:user) {
    User.new(
      :email => 'test@test.com',
      :name => 'Testy McTesterson'
    )
  }
  
  it 'can be created' do
    sharelink.should_not be_nil
  end
  
  it 'has a value' do
    sharelink.value.should_not be_nil
  end
  
  it 'is given a random value' do
    Sharelink.new.value.should_not == Sharelink.new.value
  end
  
  it 'can belong to an experiment' do
    sharelink.experiment = experiment
    sharelink.save
    experiment.sharelinks.first.id.should == sharelink.id
  end
  
  it 'can belong to a dataset' do
    sharelink.dataset = dataset
    sharelink.save
    dataset.sharelinks.first.id.should == sharelink.id
  end
  
  it 'cannot be given both a Dataset and an Experiment' do
    sharelink.dataset = dataset
    sharelink.experiment = experiment
    Proc.new { sharelink.save }.should raise_error DataMapper::SaveFailureError
  end
  
  it 'must have either a Dataset or an Experiment' do
    Proc.new { sharelink.save}.should raise_error DataMapper::SaveFailureError
  end
end
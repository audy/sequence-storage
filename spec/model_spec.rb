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
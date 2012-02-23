ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'application')

require 'rack/test'
require 'webrat'

set :logging, false

Webrat.configure do |config|
  config.mode = :rack
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Webrat::Matchers
  config.include Webrat::Methods
  
  config.filter_run_excluding :broken => true
  
  config.before(:each) { DataMapper.auto_migrate! }
end

def app
  Sinatra::Application
end
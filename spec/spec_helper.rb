require File.join(File.dirname(__FILE__), '..', 'application')

require 'rack/test'
require 'webrat'

set :environment, :test
set :logging, false

# Setup in-memory database for testing.
DataMapper.setup(:default, "sqlite3::memory:")

Webrat.configure do |config|
  config.mode = :rack
end

RSpec.configure do |config|
  
  def app
    Sinatra::Application
  end
  
  config.before(:each) { DataMapper.auto_migrate! }
  config.include Rack::Test::Methods
  config.include Webrat::Matchers
  config.include Webrat::Methods
end
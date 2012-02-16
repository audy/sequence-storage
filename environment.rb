# Gems
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'bcrypt'
require 'json'
require 'securerandom'

# Load and finalize models
require './models.rb'

DataMapper.finalize

configure :development do
  FILES_ROUTE = "files"
  require 'sinatra/reloader'
  DataMapper.setup(:default,
                   :adapter => 'sqlite',
                   :database => File.join('db', 'development.db'))
  DataMapper::Model.raise_on_save_failure = true
  DataMapper.auto_upgrade!
end

configure :test do
  FILES_ROUTE = "."
  DataMapper.setup(default, "sqlite::memory:")
  DataMapper::Model.raise_on_save_failure = true
  DataMapper.auto_migrate!
end

configure :production do
  FILES_ROUTE = "/var/dataman/"
  DataMapper.setup(default, ENV['DB_URL'])
end

enable :sessions
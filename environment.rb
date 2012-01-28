# Gems
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'bcrypt'

# Load and finalize models
require './models.rb'
DataMapper.finalize

configure :development do
  require 'sinatra/reloader'
  DataMapper.setup(:default,
                   :adapter => 'sqlite',
                   :database => File.join('db', 'development.db'))
  DataMapper::Model.raise_on_save_failure = true 
  DataMapper.auto_upgrade!
end

configure :test do
  DataMapper.setup(default, "sqlite::memory:")
  DataMapper.auto_migrate!
end

enable :sessions
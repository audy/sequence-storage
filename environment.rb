# Gems
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'bcrypt'
require 'json'
require 'securerandom'
require 'aws/s3'

# Load and finalize models
require './models.rb'

DataMapper.finalize

AWS_ACCESS_KEY = ENV['AWS_ACCESS_KEY']
AWS_SECRET = ENV['AWS_SECRET']
FILES_ROUTE = ENV['FILES_ROUTE']

configure :development do
  require 'sinatra/reloader'
  $stderr.puts 'development!'
  DataMapper.setup(:default,
                   :adapter => 'sqlite',
                   :database => ENV['DB_URL'] || File.join('db', 'development.db'))
  DataMapper::Model.raise_on_save_failure = true 
  DataMapper.auto_upgrade!
end

configure :test do
  DataMapper.setup(:default, "sqlite::memory:")
  DataMapper::Model.raise_on_save_failure = true
  DataMapper.auto_migrate!
end

configure :production do
  DataMapper.setup(:default, :adapter => 'sqlite', :database => ENV['DB_URL'])
end

enable :sessions
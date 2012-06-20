# Gems
require 'sinatra'
require 'sinatra/config_file'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'bcrypt'
require 'json'
require 'securerandom'
require 'aws/s3'
require 'rdiscount'

# Load and finalize models
require './models.rb'

DataMapper.finalize

config_file 'config/config.yml'

use :sessions

# TODO, just access these variables using settings
AWS_ACCESS_KEY = settings.aws_access_key
AWS_SECRET     = settings.aws_secret
FILES_ROUTE    = settings.files_route
BUCKET_NAME    = settings.bucket_name
DATABASE       = settings.database

# Connect to S3 bucket
class DatasetFile < AWS::S3::S3Object
  set_current_bucket_to BUCKET_NAME
end

# Connect to database
DataMapper.setup(:default, :adapter => 'sqlite', :database => settings.database)

# Raise actual errors when something goes wrong
DataMapper::Model.raise_on_save_failure = true

configure :development do  
  require 'sinatra/reloader'
  DataMapper.auto_upgrade!
end

configure :test do
  DataMapper.auto_migrate!
end


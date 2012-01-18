# Gems
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'bcrypt'

# Local stuff
require './models.rb'

# Setup environment
# ENV can be :development or :production
# This isn't really being used at the moment
ENVIRONMENT = ENV['SINATRA_ENV'] || :development

# Setup Database
DataMapper.finalize
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://' + File.expand_path(File.dirname(__FILE__)) + '/db/development.db')

enable :sessions
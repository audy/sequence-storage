require 'sinatra' unless defined?(Sinatra)
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'bcrypt'
require './models.rb'

ENVIRONMENT = :development

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://' + File.expand_path(File.dirname(__FILE__)) + '/db/development.db')

enable :sessions

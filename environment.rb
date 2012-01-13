require 'sinatra' unless defined?(Sinatra)
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require './models.rb'

ENVIRONMENT = :deveopment

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://' + File.expand_path(File.dirname(__FILE__)) + '/db/development.db')
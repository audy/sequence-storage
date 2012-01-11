require 'sinatra' unless defined?(Sinatra)
require 'dm-core'
require './models.rb'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://db/development.db')
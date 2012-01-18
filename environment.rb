# Gems
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'bcrypt'

# Local stuff
require './models.rb'

set :environment, :development
set :root, File.expand_path(File.dirname(__FILE__))

case settings.environment
  when :production
    set :db_url, ENV['DATABASE_URL']
  when :development
    set :db_url, "sqlite3://#{settings.root}/db/development.db"
    require 'sinatra/reloader'
end

$stderr.puts settings.db_url.inspect

# Setup Database
DataMapper.finalize
DataMapper.setup(:default, settings.db_url)

enable :sessions
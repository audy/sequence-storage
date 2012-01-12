
desc "start application console"
task :console do
  require 'irb'
  load 'environment.rb'
  ARGV.clear
  IRB.start
end

namespace :db do
  
  desc "create the database"
  task :create do
    
    load 'environment.rb'
    config = DataMapper.repository.adapter.options.symbolize_keys
    $stderr.puts config.inspect
    DataMapper.setup(DataMapper.repository.name, config)
    
  end
  
  desc "auto migrate the database"
  task :automigrate do
    load 'environment.rb'
    DataMapper.auto_migrate!
  end
end
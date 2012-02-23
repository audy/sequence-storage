
desc "start application console"
task :console do
  require 'irb'
  load 'environment.rb'
  ARGV.clear
  IRB.start
end

desc "run rspec"
task :spec do
  sh "rspec"
end

namespace :db do

  desc "seed the database with informatione"
  task :seed do
    load 'environment.rb'
    10.times do |n|
      e = Experiment.new
      e.name = "Experiment #{n}"
      e.description = "generated by `rake db:seed`"
      e.save
    end
  end

  desc "create the database"
  task :create do
    load 'environment.rb'
    config = DataMapper.repository.adapter.options.symbolize_keys
    DataMapper.setup(DataMapper.repository.name, config)

  end

  desc "auto migrate the database"
  task :automigrate do
    fail 'DONT DO THIS ON PRODUCTION' if ENV['RACK_ENV'] == 'production'
    load 'environment.rb'
    DataMapper.auto_migrate!
  end
  
  desc "auto upgrade the database"
  task :autoupgrade do
    load 'environment.rb'
    DataMapper.auto_upgrade!
  end
end

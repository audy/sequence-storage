
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

desc "delete old sharelinks"
task :delete_old do
  load 'environment.rb'
  puts "Deleting all old sharelinks\n\ "
  old_shares = Sharelink.all(:expire_at.lt => Time.now.to_date)

  old_shares.each do |share|
    puts  share.value
    if share.destroy
      puts "deleted!"
    else
      puts "error: could not delete"
    end
  end
  puts "Finish deleting"
end

desc "update any datasets with default file size and md5"
task :update_files do
  load 'environment.rb'
  puts "\n\nupdating files with default size and md5, using localserver's files info\n\n"

  Dataset.each do |d|
    puts "#{d.name}"
    file_exists = true
    p = File.expand_path(File.join(FILES_ROUTE, d.path))
    if d.size == 100
      if file_exists = (File.exist? p)
        new_file_size = File.new(p).size
        if d.update(:size => new_file_size)
          puts "  updated size to #{new_file_size}"
        else
          puts "  update size error"
        end
      else
        puts "  update error: file not in local server"
      end
    end

    if d.mdsum == "ok" && file_exists
      local_md5 = Digest::MD5.file(p)
      if d.update(:mdsum => local_md5)
        puts "  updates md5 to #{local_md5}"
      else
        puts "  update md5 error"
      end
    end
  end
  puts "done!"
end

desc 'create datasets from s3'
task :create_files do
  load 'environment.rb'
  
  AWS::S3::Base.establish_connection!(
    :access_key_id     => AWS_ACCESS_KEY,
    :secret_access_key => AWS_SECRET
  )
 
  bucket = AWS::S3::Bucket.find(BUCKET_NAME)
  baby = bucket.objects
  
  user = User.get(USER_NUM)
  
  num_files_created = 0
  num_dataset_missing = 0
  num_dataset_here = 0
  access = 0;

  USER_NUM = 5
   
  if user
    puts "Using user #{user.id}, #{user.name}"
  else
    puts "error: Cannot get user #{USER_NUM}"
    exit  
  end

  baby.each do |b|

    filename = b.path.gsub("/#{BUCKET_NAME}/", "")
    dirname = File.dirname(filename)
    # Check if the dataset is in s3, create it, if not.
    if !Dataset.first(:path => filename)

      size = b.size # gets file size from s3

      # file has to be greater than zero, so directorys will not be created as datasets
      if size.to_i > 0

        experiment = Experiment.first_or_create({:name => dirname},{:description => "Created on #{Time.now} by #{user.name}"})
        if experiment.users.first.nil?
          user.experiments << experiment
          user.save
          puts "#{experiment.name} linked to #{user.name}"
        end
        break if !experiment

        # create dataset
        chksum  = b.about['etag'].tr('"','')

        file = Dataset.new
        file.path   = filename
        file.size   = size
        file.mdsum  = chksum  # get checksum from s3,
        file.last_modified = DateTime.now
        file.experiment = experiment
        file.user = user

        if file.save 
          puts "#{filename} created"
          num_files_created = num_files_created + 1
        else
          puts "error: #{filename} could not be created"
        end
        num_dataset_missing = num_dataset_missing + 1
      end
    else
      puts "Here!  #{filename}"
      num_dataset_here = num_dataset_here + 1
    end
  end

  puts "\nThe number of datasets missing were #{num_dataset_missing}"
  puts "The number of datasets created were #{num_files_created}"
  puts "#{num_dataset_missing - num_files_created} were not created due to errors"
  puts "The number of datasets that exists before creation is #{num_dataset_here}"
end

desc 'check mdsum'
task :check_md5 do
  require './environment'

  AWS::S3::Base.establish_connection!(
    :access_key_id     => AWS_ACCESS_KEY,
    :secret_access_key => AWS_SECRET
  )

  bucket = AWS::S3::Bucket.find('triplett-sequence-bucket', :prefix => 'baby_metagenomes') 
  baby = bucket.objects
  puts "\n\n\nchecking for files in #{FILES_ROUTE}\n\n"
  count=0
  am_count=0
  md5_count=0
  am_ds_count=0
  am_ds_mismatch=0
  total_md5_count=0

  Dataset.each do |d|
    local_file_present  = false 
    amazon_file_present = false
    p = File.expand_path(File.join(FILES_ROUTE, d.path))
    if File.exist? p
      localmd5 = Digest::MD5.file(p)
      puts "exists\t#{p}\t#{localmd5}" 
      local_file_present = true;
    else
     puts "missing\t#{p}\t"
     count += 1
    end
    
    if bucket[d.path]

      jobj = bucket[d.path].about['etag'].tr('"','')
      amazonmd5 = jobj
      puts "size: #{bucket[d.path].size}\t #{amazonmd5}"
      amazon_file_present = true;
    else
      puts "file not found on amazon"
      am_count += 1
    end

    if local_file_present && amazon_file_present

      total_md5_count += 1
      if localmd5 == amazonmd5
        puts "The md5 does match"
      else
        ms5_count += 1
        puts "The md5 does NOT match"
      end
    end

    if amazon_file_present  && amazonmd5 == d.mdsum
      puts "amazon m5sum matched with dataset md5sum"
      am_ds_count += 1
    else
      puts "amazon m5sum NOT matched with dataset md5sum"
      am_ds_mismatch += 1
    end
    puts ""
  end
  puts "There are #{count} files missing from local server"
  puts "There are #{am_count} files missing from amazon s3"
  puts "The total local server to s3 md5 compared: #{total_md5_count}"
  puts "There are #{total_md5_count - md5_count} compares that match"
  puts "There are #{md5_count} compares that do NOT match"
  puts "#{am_ds_count} out of #{am_ds_count + am_ds_mismatch} amazon md5 compares with datset md5 match\n"
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

#!/usr/bin/env ruby

require './environment'

AWS::S3::Base.establish_connection!(
  :access_key_id     => AWS_ACCESS_KEY,
  :secret_access_key => AWS_SECRET
)

puts "\n"

bucket = AWS::S3::Bucket.find(BUCKET_NAME)
baby = bucket.objects

num_files_created = 0
num_dataset_missing = 0
num_dataset_here = 0
access = 0;

USER_NUM = 5
if user = User.get(USER_NUM) 
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
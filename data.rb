#!/usr/bin/env ruby

require './environment'

AWS::S3::Base.establish_connection!(
  :access_key_id     => AWS_ACCESS_KEY,
  :secret_access_key => AWS_SECRET
)

bucket = AWS::S3::Bucket.find(BUCKET_NAME)
baby = bucket.objects

num_files_created = 0
num_dataset_missing = 0
num_dataset_here = 0
access = 0;
puts "\n"

## This creates an experiment even if no datasets are missing, not good ##
experiment = Experiment.new
experiment.name = BUCKET_NAME
experiment.description = "Created on #{Time.now} by Data for #{BUCKET_NAME}"
if experiment.save
  puts 'New experiment created'
  access = access + 1
end

if user = User.get(5) 
  puts "Using user #{user.id}, #{user.name}"
  access = access + 1
end  

baby.each do |b|

    puts filename = b.path.gsub("/#{BUCKET_NAME}/", "")
    if !Dataset.first(:path => filename)
      
      size = b.size # gets file size from s3
      if size.to_i >  0 && access == 2
        # create dataset
        unparsed_chksum  = b.about().to_a[4][1]
        
        file = Dataset.new
        puts file.path   = filename
        puts file.size   = size
        puts file.mdsum  = unparsed_chksum[3..unparsed_chksum.length]  # get checksum from s3,
        puts file.experiment = experiment
        puts file.user = user
        if file.save 
          puts "#{filename} created"
          num_files_created = num_files_created + 1
        else
          puts "error: #{filename} could not be created"
        end
        num_dataset_missing = num_dataset_missing + 1
      end
    else
      puts "Here!"
      num_dataset_here = num_dataset_here + 1
    end
end

puts "\nThe number of datasets missing were #{num_dataset_missing}"
puts "The number of datasets created were #{num_files_created}"
puts "#{num_dataset_missing - num_files_created} were not created due to errors"
puts "The number of datasets that exists before creation is #{num_dataset_here}"
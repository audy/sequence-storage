#!/usr/bin/env ruby

require './environment'
require './helpers'
require 'json'
require 'digest/md5'

AWS::S3::Base.establish_connection!(
  :access_key_id     => AWS_ACCESS_KEY,
  :secret_access_key => AWS_SECRET
)

bucket = AWS::S3::Bucket.find('triplett-sequence-bucket', :prefix => 'baby_metagenomes') 
baby = bucket.objects.inspect
puts "\n\n\nchecking for files in #{FILES_ROUTE}\n\n"
count=0
am_count=0
md5_count=0
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
   count = count + 1
  end

  if obj = bucket[d.path]
    jobj = obj.about().to_a[4][1]
    amazonmd5 = jobj[3..jobj.length]
    puts "size: #{obj.size}\t #{amazonmd5}"
	amazon_file_present = true;
  else
    puts "file not found on amazon"
    am_count = am_count + 1
  end
    
  if local_file_present && amazon_file_present
    
    total_md5_count = total_md5_count + 1
    if localmd5 == amazonmd5
      puts "The md5 does match"
    else
      ms5_count = md5_count + 1
      puts "The md5 does NOT match"
    end
  end
  puts ""
end
puts "There are #{count} files missing from local server"
puts "There are #{am_count} files missing from amazon s3"
puts "The total md5sum compared: #{total_md5_count}"
puts "There are #{total_md5_count - md5_count} compares that match"
puts "There are #{md5_count} compares that do NOT match"
puts ""
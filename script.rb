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
count=0;
am_count=0;
Dataset.each do |d|
    local_file_present = false; 
    amazon_file_present = false;
	p = File.expand_path(File.join(FILES_ROUTE, d.path))
	if File.exist? p
		print "exists\t#{p}\t" 
		print localmd5 = Digest::MD5.file(p)
		local_file_present = true;
	else
		print "missing\t#{p}\t"
		count = count + 1;
	end
	
	if obj = bucket[d.path]
	  print "\nsize: "
	  print obj.size
	  jobj = obj.about().to_a[4][1]
	  amazonmd5 = jobj.inspect[3..jobj.length]
	  print "\t #{amazonmd5}"
	  amazon_file_present = true;
	else
	  print "\nfile not found on amazon"
	  am_count = am_count + 1;
	end
    
    if local_file_present && amazon_file_present
      if localmd5 == amazonmd5
        print "\nThe md5 does match"
      else
        print "\nTne md5 does NOT match"
      end
    end
    print "\n\n"
end
puts "There are #{count} files missing from local server"
puts "There are #{am_count} files missing from amazon s3"
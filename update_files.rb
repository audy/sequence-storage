#!/usr/bin/env ruby

require './environment'
require 'digest/md5'

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


#!/usr/bin/env ruby

def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end

puts "Which file?"
filename = gets
filename.chomp!.strip!

data_string = get_file_as_string("../data/#{filename}")

data = data_string.split(",").collect{|i| i.to_i}

puts "Original size: #{data.size}"

data.sort!
data.uniq!

File.truncate("../data/#{filename}",0)
data.each do |d|
  File.open("../data/#{filename}","a"){|f| f.write("#{d.to_s},")}
end

puts "New size: #{data.size}"
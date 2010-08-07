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

new_data_string = get_file_as_string("../data/#{filename}")
new_data = new_data_string.split(",").collect{|i| i.to_i}


total_data_string = get_file_as_string("../data/total_pak_ids")
total_data = total_data_string.split(",").collect{|i| i.to_i}

count = 0

puts "Original size: #{new_data.size}"

data = new_data - (total_data & new_data)

data.each do |d|
  File.open("../data/new_id_file","a"){|f| f.write("#{d.to_s},")}
end

puts "New ids: #{data.size}"
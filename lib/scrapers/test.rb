#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'development'

require '../../config/environment' #only if you are using this within a rails app
require 'rubygems'
require 'net/http'
require 'rexml/document'

def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end



xml_data = get_file_as_string("../summaries/pak_results.txt")

doc = REXML::Document.new(xml_data)

ngo_search_results_hash = {}

doc.elements.each('root/result/') do |ele|
   puts ele.elements["ngo_name"].text unless ele.elements["ngo_name"].nil?
   puts ele.elements["location"].text unless ele.elements["location"].nil?
   puts ele.elements["category0"].text unless ele.elements["category0"].nil?
   puts ele.elements["category1"].text unless ele.elements["category1"].nil?
   puts ele.elements["category2"].text unless ele.elements["category2"].nil?
   puts ele.elements["category3"].text unless ele.elements["category3"].nil?
   puts ele.elements["category4"].text unless ele.elements["category4"].nil?
   puts ele.elements["category5"].text unless ele.elements["category5"].nil?
   puts ele.elements["category6"].text unless ele.elements["category6"].nil?
   puts ele.elements["category7"].text unless ele.elements["category7"].nil?
   
   ngo_search_results_hash[acronym] = {:acronym => acronym, 
                                       :name => full_name, 
                                       :contact_name => "", 
                                       :contact_position => "",
                                       :contact_address => address,
                                       :contact_phone => office_phone,
                                       :contact_email => office_email,
                                       :district => location,
                                       :affiliation => affiliation,
                                       :sector => sector,
                                       :country => ""}
   
end



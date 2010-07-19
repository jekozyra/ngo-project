#!/usr/bin/env ruby

require 'rexml/document'
require 'rubygems'
require 'hpricot'
require 'scrubyt'
require 'open-uri'

start = Time.now

def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end

pak_data = Scrubyt::Extractor.define :agent => :firefox do
 
  url = 'http://www.ngosinfo.gov.pk/SearchResults.aspx?name=&foa=0'
  fetch url

  result "/html" do
    result_body "/body", :type => :html_subtree
  end

  next_page 'Next', :limit => 10
  
end

File.open("../summaries/pak_results2.txt", 'w') {|f| f.write(pak_data.to_xml) }

result_string = Hpricot(get_file_as_string("../summaries/pak_results2.txt"))

File.truncate("../summaries/pak_results3.txt", 0)
result_string.search("//result/result_body/") do |text|
  File.open("../summaries/pak_results3.txt", 'a') {|f| f.write(text) }
end

parsed_page = result_string = Hpricot(get_file_as_string("../summaries/pak_results3.txt"))

id_array = []

File.truncate("../summaries/pak_results4.txt", 0)
parsed_page.search("a.NgoSearch") do |text|
  File.open("../summaries/pak_results4.txt", 'a') {|f| f.write("#{text.attributes['onclick'].split(",")[1]},") }
  #id_array << text.attributes['onclick'].split(",")[1].to_i
end

#ngo_search_results_hash = {}

=begin
id_array.each do |id|
  
  page = Hpricot(open("http://www.ngosinfo.gov.pk/ViewNgoDetails.aspx?id=#{id}"))
  
  ngo_search_results_hash[acronym] ={:acronym => acronym, 
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
=end


puts "\nTime elapsed: #{Time.now - start} seconds"
#!/usr/bin/env ruby

require 'rexml/document'
require 'rubygems'
require 'hpricot'
require 'scrubyt'
require 'open-uri'


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

File.open("../data/pak_data_xml", 'w') {|f| f.write(pak_data.to_xml) }

result_string = Hpricot(get_file_as_string("../data/pak_data_xml"))

File.truncate("../data/pak_data_parsed", 0)
result_string.search("//result/result_body/") do |text|
  File.open("../data/pak_data_parsed", 'a') {|f| f.write(text) }
end

parsed_page = result_string = Hpricot(get_file_as_string("../data/pak_data_parsed"))

id_array = []

File.truncate("../data/pak_data_id_file", 0)
parsed_page.search("a.NgoSearch") do |text|
  File.open("../data/pak_data_id_file", 'a') {|f| f.write("#{text.attributes['onclick'].split(",")[1]},") }
end


=begin

pak_data = Scrubyt::Extractor.define :agent => :firefox do
 
  url = 'http://www.ngosinfo.gov.pk/SearchResults.aspx?name=&foa=0'
  fetch url
  
  result "//body" do
    ngo_name "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_lblSubject']"
    location "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_Label2']"
    category0 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_FoaDataList_ctl00_lblFoa']"
    category1 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_FoaDataList_ctl01_lblFoa']"
    category2 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_FoaDataList_ctl02_lblFoa']"
    category3 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_FoaDataList_ctl03_lblFoa']"
    category4 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_FoaDataList_ctl04_lblFoa']"
    category5 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_FoaDataList_ctl05_lblFoa']"
    category6 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_FoaDataList_ctl06_lblFoa']"
    category7 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl00_FoaDataList_ctl07_lblFoa']"
  end
  
  result "//body" do
    ngo_name "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_lblSubject']"
    location "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_Label2']"
    category0 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_FoaDataList_ctl00_lblFoa']"
    category1 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_FoaDataList_ctl01_lblFoa']"
    category2 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_FoaDataList_ctl02_lblFoa']"
    category3 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_FoaDataList_ctl03_lblFoa']"
    category4 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_FoaDataList_ctl04_lblFoa']"
    category5 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_FoaDataList_ctl05_lblFoa']"
    category6 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_FoaDataList_ctl06_lblFoa']"
    category7 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl01_FoaDataList_ctl07_lblFoa']"
  end
  
  result "//body" do
    ngo_name "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_lblSubject']"
    location "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_Label2']"
    category0 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_FoaDataList_ctl00_lblFoa']"
    category1 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_FoaDataList_ctl01_lblFoa']"
    category2 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_FoaDataList_ctl02_lblFoa']"
    category3 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_FoaDataList_ctl03_lblFoa']"
    category4 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_FoaDataList_ctl04_lblFoa']"
    category5 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_FoaDataList_ctl05_lblFoa']"
    category6 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_FoaDataList_ctl06_lblFoa']"
    category7 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl02_FoaDataList_ctl07_lblFoa']"
  end
  
  result "//body" do
    ngo_name "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_lblSubject']"
    location "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_Label2']"
    category0 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_FoaDataList_ctl00_lblFoa']"
    category1 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_FoaDataList_ctl01_lblFoa']"
    category2 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_FoaDataList_ctl02_lblFoa']"
    category3 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_FoaDataList_ctl03_lblFoa']"
    category4 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_FoaDataList_ctl04_lblFoa']"
    category5 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_FoaDataList_ctl05_lblFoa']"
    category6 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_FoaDataList_ctl06_lblFoa']"
    category7 "//span[@id='ctl00_ContentPlaceHolder1_NGOsDataList_ctl03_FoaDataList_ctl07_lblFoa']"
  end
    
  next_page 'Next', :limit => 10

end

#puts pak_data.to_xml

File.open("../summaries/pak_results.txt", 'w') {|f| f.write(pak_data.to_xml) }

=end


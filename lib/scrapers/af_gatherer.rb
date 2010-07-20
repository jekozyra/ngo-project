#!/usr/bin/env ruby

=begin
http://acbar.org/index.php?option=com_sobi2&sobi2Task=sobi2Details&catid=2&sobi2Id=11&Itemid=
=end

require 'rexml/document'
require 'rubygems'
require 'hpricot'
require 'open-uri'


def scrape
  
  puts "SCRAPING..."
  
  base_urls = []

  afghan_ngo_base_url = "http://acbar.org/index2.php?sobi2Search=&searchphrase=any&SobiCatSelected_0=3&field_member=all&field_affiliation=all&option=com_sobi2&Itemid=0&no_html=1&sobi2Task=axSearch&sobiCid=3&SobiSearchPage="
  international_organisation_base_url = "http://acbar.org/index2.php?sobi2Search=&searchphrase=any&SobiCatSelected_0=9&field_member=all&field_affiliation=all&option=com_sobi2&Itemid=0&no_html=1&sobi2Task=axSearch&sobiCid=9&SobiSearchPage="
  international_ngo_base_url = "http://acbar.org/index2.php?sobi2Search=&searchphrase=any&SobiCatSelected_0=8&field_member=all&field_affiliation=all&option=com_sobi2&Itemid=0&no_html=1&sobi2Task=axSearch&sobiCid=8&SobiSearchPage="
  un_agency_base_url = "http://acbar.org/index2.php?sobi2Search=&searchphrase=any&SobiCatSelected_0=10&field_member=all&field_affiliation=all&option=com_sobi2&Itemid=0&no_html=1&sobi2Task=axSearch&sobiCid=10&SobiSearchPage="
  mfi_base_url = "http://acbar.org/index2.php?sobi2Search=&searchphrase=any&SobiCatSelected_0=18&field_member=all&field_affiliation=all&option=com_sobi2&Itemid=0&no_html=1&sobi2Task=axSearch&sobiCid=18&SobiSearchPage="
  donor_base_url = "http://acbar.org/index2.php?sobi2Search=&searchphrase=any&SobiCatSelected_0=11&field_member=all&field_affiliation=all&option=com_sobi2&Itemid=0&no_html=1&sobi2Task=axSearch&sobiCid=11&SobiSearchPage="
  others_base_url = "http://acbar.org/index2.php?sobi2Search=&searchphrase=any&SobiCatSelected_0=19&field_member=all&field_affiliation=all&option=com_sobi2&Itemid=0&no_html=1&sobi2Task=axSearch&sobiCid=19&SobiSearchPage="


  base_urls << afghan_ngo_base_url
  base_urls << international_ngo_base_url
  base_urls << international_organisation_base_url
  base_urls << un_agency_base_url
  base_urls << mfi_base_url
  base_urls << donor_base_url
  base_urls << others_base_url

  ngo_urls = []

  base_urls.each do |base_url|
  
    last_page = false
    page_number = 0
    result_number = 0
    ngo_search_results_hash = {}
  
    # loop over all of the pages in the results
    while !last_page # and page_number < 3
      url = base_url + page_number.to_s
  
      page = Hpricot(open(url))

      if page.at("//table[2]").nil?
        last_page = true
      end

      page.search("//table[2]/tr//td/p.sobi2ItemTitle/a").each do |link|
        ngo_urls << link['href']
      	result_number += 1
      end

      page_number += 1

    end #end while
  
  end
  
  return ngo_urls
  
end # end function scrape


if __FILE__ == $0

  af_data = scrape
  
  puts "DONE SCRAPING, WRITING DATA..."

  File.open("../data/af_data_id_file", 'w') {|f| af_data.each{|url| f.write("#{url},")} }
  
end


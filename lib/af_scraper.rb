#!/usr/bin/env ruby

#require '../config/environment' #only if you are using this within a rails app
require 'rexml/document'
require 'rubygems'
require 'hpricot'
require 'open-uri'

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

    page.search("//table[2]/tr//td").each do |row|
    	acronym = (row%"p.sobi2ItemTitle/a/").to_plain_text.chomp.strip
    	full_name = (row%"span.sobi2Listing_field_organisation_full_name/").to_plain_text.chomp.strip
    	(row/"span.sobi2Listing_field_affiliation_label").remove
    	unless (row%"span.sobi2Listing_field_affiliation/").nil?
    	  affiliation = (row%"span.sobi2Listing_field_affiliation/").to_plain_text.chomp.strip
    	end
    	(row/"span.sobi2Listing_field_location_label").remove
    	location = (row%"span.sobi2Listing_field_location/").to_plain_text.chomp.strip
    	(row/"span.sobi2Listing_field_address_label").remove
    	address = (row%"span.sobi2Listing_field_address/").to_plain_text.chomp.strip
    	(row/"span.sobi2Listing_field_office_email_label").remove
    	office_email = (row%"span.sobi2Listing_field_office_email/").to_plain_text.chomp.strip
    	(row/"span.sobi2Listing_field_office_phone_label").remove
    	office_phone = (row%"span.sobi2Listing_field_office_phone/").to_plain_text.chomp.strip
    	(row/"span.sobi2Listing_field_sector_label").remove
    	unless (row%"span.sobi2Listing_field_sector/").nil?
    	  sector = (row%"span.sobi2Listing_field_sector/").to_plain_text.chomp.strip
    	end
  	
    	# add search result to hash
  	
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
  	
    	result_number += 1
    end

    page_number += 1

  end


  ngo_search_results_hash.each do |key, item|

    # since the sectors are entered as a string separated by . or , or / we need to parse them and also correct capitalisation
    sectors = []
    unless item[:sector].nil?
    
      sector_array = []
    
      # if sector contains / or . or , split on based on these delimiters
      if item[:sector].include?("/") or item[:sector].include?(",") or item[:sector].include?(".")
        sector_array = item[:sector].split(/[,.\/]/)
      else
        sector_array << item[:sector]
      end
  
      sector_array.each do |sector| 
        if sector.strip.chomp.casecmp("Emergency Assistant") == 0
          sector = "Emergency Assistance"
        elsif sector.strip.chomp.casecmp("WATSAN") == 0
          sector = "Water Sanitation"
        elsif sector.strip.chomp.casecmp("Transprot") == 0
          sector = "Transport"
        elsif sector.strip.chomp.casecmp("Caoacity Building") == 0 or sector.strip.chomp.casecmp("CapacityBuilding") == 0
          sector = "Capacity Building"
        elsif sector.strip.chomp.casecmp("Agricalture") == 0
          sector = "Agriculture"
        elsif sector.strip.chomp.casecmp("Emergy") == 0
          sector = "Energy"
        elsif sector.strip.chomp.casecmp("Heath") == 0
          sector = "Health"
        end
        sectors << sector.strip.chomp.gsub(/\b\w/){$&.upcase}
      end
        
    end # end unless item[:sector].nil


    # since the affiliations are entered as a string separated by & or / we need to parse them and also correct capitalisation
    affiliations = []
    unless item[:affiliation].nil?
    
      affiliation_array = []
    
      # if sector contains / or . or , split on based on these delimiters
      if item[:affiliation].include?("/") or item[:affiliation].include?("&")
        affiliation_array = item[:affiliation].split(/[&\/]/)
      else
        affiliation_array << item[:affiliation]
      end
  
      affiliation_array.each do |affiliation|
        
        # typos involving Switzerland
        if affiliation.strip.chomp.casecmp("Swiss") == 0 or affiliation.strip.chomp.casecmp("Geneva") == 0
          affiliation = "Switzerland"
        # typos involving The Netherlands
        elsif (affiliation.strip.chomp.casecmp("Holland") == 0) or (affiliation.strip.chomp.casecmp("The Netherland") == 0) or (affiliation.strip.chomp.casecmp("Netherland") == 0)
          affiliation = "Netherlands"
        # typos involving the UN
        elsif affiliation.strip.chomp.casecmp("Uni") == 0
          affiliation = "United Nations"
        end
        affiliations << affiliation.strip.chomp.gsub(/\b\w/){$&.upcase}
      end
        
    end # end unless item[:sector].nil

    # this is the scraping script for Afghanistan, and we know that's where the NGOs are based 
    item[:country] = "Afghanistan"

    # if the country for the NGO does not exist, create it
    if Country.exists?(:name => item[:country])
      @country = Country.find_by_name(item[:country]).id
    else
      @country = Country.create(:name => item[:country]).id
    end
  

    # if the district for the NGO does not exist, create it
    if District.exists?(:name => item[:district])
      @district = District.find_by_name(item[:district]).id
    else
      @district = District.create(:name => item[:district], :country_id => @country).id
    end
  
    ngo_params = {:acronym => item[:acronym],
                  :name => item[:name],
                  :contact_address => item[:contact_address],
                  :contact_phone => item[:contact_phone],
                  :contact_email => item[:contact_email],
                  :district_id => @district,
                  :country_id => @country}
 
    # check to see if the ngo exists; if not, create it, otherwise, update it
    if Ngo.exists?(:name => item[:name]) and Ngo.exists?(:acronym => item[:acronym])
      @ngo = Ngo.find(:first, :conditions => ["name = ? and acronym = ?", item[:name], item[:acronym]])
      if @ngo.auto_update
        @ngo.update_attributes(ngo_params)
      end
    else
      @ngo = Ngo.create(ngo_params)
    end
                    
    # loop through the sectors and create them if they don't already exist
    if @ngo.auto_update
      if item[:affiliation].nil?
        @affiliation = nil
      else
        
        # if the affiliation(s) for the NGO does not exist, create it
        affiliations.each do |affiliation|
          unless affiliation == ""
            if Affiliation.exists?(:name => affiliation)
              affiliation = Affiliation.find_by_name(affiliation)
            else
              affiliation = Affiliation.create(:name => affiliation)
            end
      
            unless @ngo.affiliation_names.include?(affiliation.name)
              @ngo.affiliations << affiliation
            end
          end
        end # end loop
      end
      
      if item[:sector].nil?
        @sector = nil
      else  
        # if the sector(s) for the NGO does not exist, create it
        sectors.each do |sector|
          unless sector == ""
            if Sector.exists?(:name => sector)
              sector = Sector.find_by_name(sector)
            else
              sector = Sector.create(:name => sector)
            end
      
            unless @ngo.sector_names.include?(sector.name)
              @ngo.sectors << sector
            end
          end
        end # end sectors loop
      end # end of this if-else block
    end # end if @ngo.auto_update

  end # end while loop
end
#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'production'

require '../../config/environment' #only if you are using this within a rails app
require 'rexml/document'
require 'rubygems'
require 'hpricot'
require 'open-uri'

def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end

url_array = get_file_as_string("../data/af_data_id_file").split(",")

ngo_search_results_hash = {}

url_array.each do |url|
  page = Hpricot(open(url))
  
  if (page%"table.sobi2Details/tr[1]/td/h1/").nil?
    puts url
  end
  
  (page%"table.sobi2Details/tr[1]/td/h1/").nil? ? acronym = nil : acronym = (page%"table.sobi2Details/tr[1]/td/h1/").to_plain_text.chomp.strip
    
  (page/"#sobi2outer").each do |row|
    
    full_name = (row%"#sobi2Details_field_organisation_full_name/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_affiliation_label").remove
    (row%"#sobi2Details_field_affiliation/").nil? ? affiliation = nil : affiliation = (row%"#sobi2Details_field_affiliation/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_location_label").remove
    (row%"#sobi2Details_field_location/").nil? ? location = nil : location = (row%"#sobi2Details_field_location/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_address_label").remove
    (row%"#sobi2Details_field_address/").nil? ? contact_address = nil : contact_address = (row%"#sobi2Details_field_address/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_office_email_label").remove
    (row%"#sobi2Details_field_office_email/").nil? ? contact_email = nil : contact_email = (row%"#sobi2Details_field_office_email/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_office_phone_label").remove
    (row%"#sobi2Details_field_office_phone/").nil? ? contact_phone = nil : contact_phone = (row%"#sobi2Details_field_office_phone/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_website_label").remove
    (row%"#sobi2Details_field_website/").nil? ? website = nil : website = (row%"#sobi2Details_field_website/").to_plain_text.chomp.strip
    
    (row/"#sobi2Listing_field_contact1_label").remove
    (row%"#sobi2Details_field_contact1/").nil? ? name1 = nil : name1 = (row%"#sobi2Details_field_contact1/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_title1_label").remove
    (row%"#sobi2Details_field_title1/").nil? ? title1 = nil : title1 = (row%"#sobi2Details_field_title1/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_mobile1_label").remove
    (row%"#sobi2Details_field_mobile1/").nil? ? phone1 = nil : phone1 = (row%"#sobi2Details_field_mobile1/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_email1_label").remove
    (row%"#sobi2Details_field_email1/").nil? ? email1 = nil : email1 = (row%"#sobi2Details_field_email1/").to_plain_text.chomp.strip
    
    (row/"#sobi2Listing_field_contact2_label").remove
    (row%"#sobi2Details_field_contact2/").nil? ? name2 = nil : name2 = (row%"#sobi2Details_field_contact2/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_title2_label").remove
    (row%"#sobi2Details_field_title2/").nil? ? title2 = nil : title2 = (row%"#sobi2Details_field_title2/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_mobile2_label").remove
    (row%"#sobi2Details_field_mobile2/").nil? ? phone2 = nil : phone2 = (row%"#sobi2Details_field_mobile2/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_email2_label").remove
    (row%"#sobi2Details_field_email2/").nil? ? email2 = nil : email2 = (row%"#sobi2Details_field_email2/").to_plain_text.chomp.strip
    
    (row/"#sobi2Listing_field_contact3_label").remove
    (row%"#sobi2Details_field_contact3/").nil? ? name3 = nil : name3 = (row%"#sobi2Details_field_contact3/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_title3_label").remove
    (row%"#sobi2Details_field_title3/").nil? ? title3 = nil : title3 = (row%"#sobi2Details_field_title3/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_mobile3_label").remove
    (row%"#sobi2Details_field_mobile3/").nil? ? phone3 = nil : phone3 = (row%"#sobi2Details_field_mobile3/").to_plain_text.chomp.strip
    (row/"#sobi2Listing_field_email3_label").remove
    (row%"#sobi2Details_field_email3/").nil? ? email3 = nil : email3 = (row%"#sobi2Details_field_email3/").to_plain_text.chomp.strip
    
    contacts = {}
    contacts["1"] = { :name => name1, :title => title1, :phone => phone1, :email => email1 }
    contacts["2"] = { :name => name2, :title => title2, :phone => phone2, :email => email2 }
    contacts["3"] = { :name => name3, :title => title3, :phone => phone3, :email => email3 }
    
    (row/"#sobi2Listing_field_sector_label").remove
    (row%"#sobi2Details_field_sector/").nil? ? sectors = nil : sectors = (row%"#sobi2Details_field_sector/").to_plain_text.chomp.strip
    
    
  	ngo_search_results_hash[acronym] ={:acronym => acronym, 
                                       :name => full_name, 
                                       :contact_address => contact_address,
                                       :contact_phone => contact_phone,
                                       :contact_email => contact_email,
                                       :district => location,
                                       :affiliation => affiliation,
                                       :sector => sectors,
                                       :contacts => contacts }
	end
 
end



# go through the hash and create/modify the ngos
ngo_search_results_hash.each do |key, item|

  # since the sectors are entered as a string separated by . or , or / we need to parse them and also correct capitalisation
  sectors = []
  unless item[:sector].nil?
  
    sector_array = []
  
    # if sector contains / or . or , split on based on these delimiters
    if item[:sector].include?("/") or item[:sector].include?(",") or item[:sector].include?(".") or item[:sector].include?("&")
      sector_array = item[:sector].split(/[,&.\/]/)
    else
      sector_array << item[:sector]
    end

    sector_array.each do |sector|
      
      if (sector.strip.chomp.casecmp("Agricalture") == 0) or (sector.strip.chomp.casecmp("Agriculture") == 0)
        sectors << "Agriculture"
      end
      
      if (sector.strip.chomp.casecmp("Caoacity Building") == 0) or (sector.strip.chomp.casecmp("CapacityBuilding") == 0) or 
         (sector.strip.chomp.casecmp("Capacity Building") == 0) or (sector.strip.chomp.casecmp("Community Development") == 0) or
         (sector.strip.chomp.casecmp("Governance") == 0) or (sector.strip.chomp.casecmp("Security") == 0)
        sectors << "Capacity Building"
      end
      
      if (sector.strip.chomp.casecmp("Coordination") == 0)
        sectors << "Coordination"
      end
      
      if (sector.strip.chomp.casecmp("Commerce & Industry") == 0)
        sectors << "Economic Issues"
      end
      
      if (sector.strip.chomp.casecmp("Education") == 0)
        sectors << "Education"
      end
      
      if sector.strip.chomp.casecmp("Emergency Assistant") == 0 or sector.strip.chomp.casecmp("Emergency Assistance") == 0
        sectors << "Emergency Services"
      end
      
      if (sector.strip.chomp.casecmp("Energy") == 0) or (sector.strip.chomp.casecmp("Emergy") == 0)
        sectors << "Energy Issues"
      end
      
      if (sector.strip.chomp.casecmp("Environment") == 0)
        sectors << "Environmental Issues"
      end
      
      if (sector.strip.chomp.casecmp("Heath") == 0) or (sector.strip.chomp.casecmp("Health") == 0)
        sectors << "Health"
      end
      
      if (sector.strip.chomp.casecmp("Transprot") == 0) or (sector.strip.chomp.casecmp("Transport") == 0) or 
         (sector.strip.chomp.casecmp("Security") == 0) or (sector.strip.chomp.casecmp("Infrastructure") == 0)
        sectors << "Infrastructure"
      end
      
      if (sector.strip.chomp.casecmp("WATSAN") == 0) or (sector.strip.chomp.casecmp("Water Sanitation") == 0)
        sectors << "Water Issues"
      end
      
      if (sector.strip.chomp.casecmp("Gender") == 0)
        sectors << "Women's Issues"
      end

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

  contacts = item[:contacts]

  # this is the scraping script for Afghanistan, and we know that's where the NGOs are based 
  item[:country] = "Afghanistan"

  # if the country for the NGO does not exist, create it
  if Country.exists?(:name => item[:country])
    @country = Country.find_by_name(item[:country]).id
  else
    @country = Country.create(:name => item[:country]).id
  end

  # if the district for the NGO does not exist, create it
  if Province.exists?(:name => item[:district])
    @province = Province.find_by_name(item[:district]).id
  else
    @province = Province.create(:name => item[:district], :country_id => @country).id
  end

  # if the district for the NGO does not exist, create it
  if District.exists?(:name => item[:district])
    @district = District.find_by_name(item[:district]).id
  else
    @district = District.create(:name => item[:district], :province_id => @province, :country_id => @country).id
  end

  ngo_params = {:acronym => item[:acronym],
                :name => item[:name],
                :contact_address => item[:contact_address],
                :contact_phone => item[:contact_phone],
                :contact_email => item[:contact_email],
                :district_id => @district,
                :province_id => @province,
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
    
    unless contacts.nil? or contacts.empty?
      contacts.each do |key, contact_info|
              
        if @ngo.find_contact?(contact_info[:name])
          contact = Contact.find(:first, :conditions => ["name = ? and id IN (?)", contact_info[:name], @ngo.contacts.map{|contact| contact.id}])
          contact.update_attributes(:name => contact_info[:name], :title => contact_info[:title], :phone => contact_info[:phone], :email => contact_info[:email])
        else
          unless contact_info[:name].nil?
            contact = Contact.create(:name => contact_info[:name], :title => contact_info[:title], :phone => contact_info[:phone], :email => contact_info[:email])
          end
        end
                
        unless contact.nil? or @ngo.has_contact?(contact)
          @ngo.contacts << contact
        end

      end
    end
    
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
    
          unless @ngo.affiliations.map{|affiliation| affiliation.id}.include?(affiliation.id)
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
            current_sector = Sector.find_by_name(sector)
          else
            current_sector = Sector.create(:name => sector)
          end
    
          unless @ngo.sectors.include?(current_sector)
            @ngo.sectors << sector
          end
        end
      end # end sectors loop
    end # end of this if-else block
  end # end if @ngo.auto_update

end # end ngo hash each




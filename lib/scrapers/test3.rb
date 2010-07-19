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


id_array = get_file_as_string("../summaries/pak_results4.txt").split(",")

ngo_search_results_hash = {}

id_array.each do |id|
  
  page = Hpricot(open("http://www.ngosinfo.gov.pk/ViewNgoDetails.aspx?id=#{id}"))
  
  full_name = page.at("#lblNgoName/")
  full_name.to_plain_text.chomp.strip unless full_name.nil?
  acronym = page.at("#lblAcronym/")
  acronym.to_plain_text.chomp.strip unless acronym.nil?
  address = page.at("#lblAddress/")
  address.to_plain_text.chomp.strip unless address.nil?
  location = page.at("#lblDistrict/")
  location.to_plain_text.chomp.strip unless location.nil?
  office_phone = page.at("#lblPhoneNo/")
  office_phone.to_plain_text.chomp.strip unless office_phone.nil?
  office_fax = page.at("#lblFaxNo/")
  office_fax.to_plain_text.chomp.strip unless office_fax.nil?
  office_email = page.at("#lblEmail/")
  office_email.to_plain_text.chomp.strip unless office_email.nil?
  office_website = page.at("#lblUrl/")
  office_website.to_plain_text.chomp.strip unless office_website.nil?
  contact_name1 = page.at("#lblContectPerson1/")
  contact_name1.to_plain_text.chomp.strip unless contact_name1.nil?
  contact_name2 = page.at("#lblContectPerson2/")
  contact_name2.to_plain_text.chomp.strip unless contact_name2.nil?
  contact_name3 = page.at("#lblContectPerson3/")
  contact_name3.to_plain_text.chomp.strip unless contact_name3.nil?
  contact_name = ""
  contact_name = "#{contact_name1}" unless contact_name1 == ""
  contact_name += ", #{contact_name2}" unless contact_name2 == ""
  contact_name += ", #{contact_name3}" unless contact_name3 == ""
  sectors = ""
  page.search("#listFoa/option/").each do |sector|
    sectors += ", " unless sectors == ""
    sectors += sector.to_plain_text.chomp.strip
  end
  
  affiliation = nil
  
  ngo_search_results_hash[full_name] ={:acronym => acronym, 
                                     :name => full_name, 
                                     :contact_name => "", 
                                     :contact_position => "",
                                     :contact_address => address,
                                     :contact_phone => office_phone,
                                     :contact_email => office_email,
                                     :contact_fax => office_fax,
                                     :website => office_website
                                     :district => location,
                                     :affiliation => affiliation,
                                     :sector => sector,
                                     :country => ""}

end

ngo_search_results_hash.each do |key, item|

  # since the sectors are entered as a string separated by , we need to parse them
  sectors = []
  unless item[:sector].nil?
  
    sector_array = item[:sector].split(",")

=begin
    sector_array.each do |sector| 
      if sector.strip.chomp.casecmp("Emergency Assistant") == 0
        sector = "Emergency Assistance"
      elsif sector.strip.chomp.casecmp("WATSAN") == 0
        sector = "Water Sanitation"
      elsif sector.strip.chomp.casecmp("Emergency Assisatance") == 0
        sector = "Emergency Assistance"
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
      
=end
  end # end unless item[:sector].nil


  # pak ngos are not given foreign affiliations
  affiliations = []
  unless item[:affiliation].nil?
      
  end # end unless item[:afilliantion].nil
  

  # this is the scraping script for Pakistan, and we know that's where the NGOs are based 
  item[:country] = "Pakistan"

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
                :contact_fax => item[:contact_fax],
                :website => itme[:website]
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

end # end ngo hash each

=begin
+------------------+--------------+------+-----+---------+----------------+
| Field            | Type         | Null | Key | Default | Extra          |
+------------------+--------------+------+-----+---------+----------------+
| id               | int(11)      | NO   | PRI | NULL    | auto_increment |
| acronym          | varchar(255) | YES  |     | NULL    |                |
| name             | varchar(255) | YES  |     | NULL    |                |
| country_id       | int(11)      | YES  |     | NULL    |                |
| district_id      | int(11)      | YES  |     | NULL    |                |
| contact_name     | varchar(255) | YES  |     | NULL    |                |
| contact_position | varchar(255) | YES  |     | NULL    |                |
| contact_address  | varchar(255) | YES  |     | NULL    |                |
| contact_phone    | varchar(255) | YES  |     | NULL    |                |
| contact_email    | varchar(255) | YES  |     | NULL    |                |
| auto_update      | tinyint(1)   | YES  |     | 1       |                |
| created_at       | datetime     | YES  |     | NULL    |                |
| updated_at       | datetime     | YES  |     | NULL    |                |
+------------------+--------------+------+-----+---------+----------------+

=end

=begin
province = page.at("#lblProvince/")
province.to_plain_text.chomp.strip unless province.nil?
/html/body/form[@id='form1']/table/tbody/tr[9]/td[2]/span[@id='lblPhone2']
/html/body/form[@id='form1']/table/tbody/tr[15]/td[2]/span[@id='lblDemographics']
/html/body/form[@id='form1']/table/tbody/tr[17]/td[2]/span[@id='lblQuantum'] # financial expenditures
/html/body/form[@id='form1']/table/tbody/tr[18]/td[2]/span[@id='lblFas'] # foreign aid
/html/body/form[@id='form1']/table/tbody/tr[19]/td[2]/span[@id='lblFinancingPartners'] # financing partners
/html/body/form[@id='form1']/table/tbody/tr[21]/td[2]/span[@id='lblRegistrationDate']
/html/body/form[@id='form1']/table/tbody/tr[22]/td[2]/span[@id='lblRegAct']
/html/body/form[@id='form1']/table/tbody/tr[24]/td[2]/span[@id='lblAoop'] # area of operation
/html/body/form[@id='form1']/table/tbody/tr[25]/td[2]/select[@id='listFoa']/option[1]
/html/body/form[@id='form1']/table/tbody/tr[25]/td[2]/select[@id='listFoa']/option[2]
=end


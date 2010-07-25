#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'production'

require '../../config/environment' #only if you are using this within a rails app
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


id_array = get_file_as_string("../data/pak_data_id_file").split(",")

ngo_search_results_hash = {}

id_array.each do |id|
  
  puts "CURRENTLY SCRAPING #{id}..."
  
  page = Hpricot(open("http://www.ngosinfo.gov.pk/ViewNgoDetails.aspx?id=#{id}"))
  
  full_name = page.at("#lblNgoName/")
  full_name = full_name.to_plain_text.chomp.strip unless full_name.nil?
  acronym = page.at("#lblAcronym/")
  acronym = acronym.to_plain_text.chomp.strip unless acronym.nil?
  address = page.at("#lblAddress/")
  address = address.to_plain_text.chomp.strip unless address.nil?
  district = page.at("#lblDistrict/")
  district = district.to_plain_text.chomp.strip unless district.nil?
  province = page.at("#lblProvince/")
  province = province.to_plain_text.chomp.strip unless province.nil?
  office_phone = page.at("#lblPhoneNo/")
  office_phone = office_phone.to_plain_text.chomp.strip unless office_phone.nil?
  office_fax = page.at("#lblFaxNo/")
  office_fax = office_fax.to_plain_text.chomp.strip unless office_fax.nil?
  office_email = page.at("#lblEmail/")
  office_email = office_email.to_plain_text.chomp.strip unless office_email.nil?
  office_website = page.at("#lblUrl/")
  office_website = office_website.to_plain_text.chomp.strip unless office_website.nil?
  contacts = {}
  contact_name1 = page.at("#lblContectPerson1/")
  contacts["1"] =  {:name => contact_name1.to_plain_text.chomp.strip} unless contact_name1.nil?
  contact_name2 = page.at("#lblContectPerson2/")
  contacts["2"] = {:name => contact_name2.to_plain_text.chomp.strip} unless contact_name2.nil?
  contact_name3 = page.at("#lblContectPerson3/")
  contacts["3"] = {:name => contact_name3.to_plain_text.chomp.strip} unless contact_name3.nil?
  sectors = []
  page.search("#listFoa/option/").each do |sector|
    sectors << sector.to_plain_text.chomp.strip unless sector.nil?
  end
  
  affiliation = nil
  
  ngo_search_results_hash[full_name] ={:acronym => acronym, 
                                     :name => full_name,
                                     :contacts => contacts,
                                     :contact_address => address,
                                     :contact_phone => office_phone,
                                     :contact_email => office_email,
                                     :contact_fax => office_fax,
                                     :website => office_website,
                                     :district => district,
                                     :province => province,
                                     :affiliation => affiliation,
                                     :sectors => sectors,
                                     :country => ""}
end

puts "STARTING TO CREATE/UPDATE..."

count = 1
ngo_search_results_hash.each do |key, item|
  
  puts "READING #{count} of #{ngo_search_results_hash.size}: #{item[:name]}..."
  
  # since the sectors are entered as a string separated by , we need to parse them
  sectors = []
  unless item[:sectors].empty?
  
    #sector_array = item[:sectors].split(",")

    item[:sectors].each do |sector|
            
      if (sector.strip.chomp.casecmp("Advocacy") == 0) or (sector.strip.chomp.casecmp("Advocacy and Awareness") == 0) or 
         (sector.strip.chomp.casecmp("Communication and Media") == 0) or (sector.strip.chomp.casecmp("Human Rights") == 0) or
         (sector.strip.chomp.casecmp("Information Dissemination") == 0) or (sector.strip.chomp.casecmp("Labour Right") == 0)
        sectors << "Advocacy"
      end
      
      if (sector.strip.chomp.casecmp("Agriculture") == 0) or (sector.strip.chomp.casecmp("Farmer field Schools") == 0) or
         (sector.strip.chomp.casecmp("Fish Farm") == 0) or (sector.strip.chomp.casecmp("LIVESTOCK") == 0)
        sectors << "Agriculture"
      end
      
      if (sector.strip.chomp.casecmp("Capacity Building") == 0) or (sector.strip.chomp.casecmp("Community Welfare / Development") == 0) or 
         (sector.strip.chomp.casecmp("Construction") == 0) or (sector.strip.chomp.casecmp("Development Of Village") == 0) or 
         (sector.strip.chomp.casecmp("Eye health and capacity building") == 0) or (sector.strip.chomp.casecmp("Humanitarian Development") == 0) or
         (sector.strip.chomp.casecmp("Industrial Home") == 0) or (sector.strip.chomp.casecmp("Industrial Relations") == 0) or
         (sector.strip.chomp.casecmp("Institution Building") == 0) or (sector.strip.chomp.casecmp("Institution Strengthening") == 0) or
         (sector.strip.chomp.casecmp("Rural Development") == 0) or (sector.strip.chomp.casecmp("Sustainable Community") == 0)
        sectors << "Capacity Building"
      end
      
      if (sector.strip.chomp.casecmp("Child labour") == 0) or (sector.strip.chomp.casecmp("Child Protection") == 0) or
         (sector.strip.chomp.casecmp("Child Sex Abuse") == 0) or (sector.strip.chomp.casecmp("Child Welfare") == 0) or
         (sector.strip.chomp.casecmp("Children Rights") == 0) or (sector.strip.chomp.casecmp("Day Care Centre") == 0) or
         (sector.strip.chomp.casecmp("Juvenile Delinquents Welfare") == 0) or (sector.strip.chomp.casecmp("MCH Centre") == 0) or
         (sector.strip.chomp.casecmp("Orphans") == 0) or (sector.strip.chomp.casecmp("Poor Student Welfare") == 0) or 
         (sector.strip.chomp.casecmp("Youth Welfare") == 0) or (sector.strip.chomp.casecmp("Youngster Welfare") == 0) or
         (sector.strip.chomp.casecmp("Welfare of Student") == 0)
        sectors << "Child Welfare"
      end
      
      if (sector.strip.chomp.casecmp("Culture") == 0)
        sectors << "Community Organizations"
      end
      
      if (sector.strip.chomp.casecmp("Co ordination") == 0)
        sectors << "Coordination"
      end
      
      if (sector.strip.chomp.casecmp("Deaf and Dumb") == 0) or (sector.strip.chomp.casecmp("Diabetic Patients") == 0) or
         (sector.strip.chomp.casecmp("Disabled Persons") == 0) or (sector.strip.chomp.casecmp("Handicapped Welfare") == 0) or
         (sector.strip.chomp.casecmp("Mentally Retarded") == 0) or (sector.strip.chomp.casecmp("Physical and Mentally Handicap") == 0) or 
         (sector.strip.chomp.casecmp("Physically Handicapped") == 0) or (sector.strip.chomp.casecmp("Welfare of Deaf") == 0) or 
         (sector.strip.chomp.casecmp("Welfare of Blinds") == 0) or (sector.strip.chomp.casecmp("Rehabilitation") == 0) or
         (sector.strip.chomp.casecmp("Rehabilitation of Disables") == 0)
        sectors << "Disablity Services"
      end
      
      if (sector.strip.chomp.casecmp("AIDS") == 0) or (sector.strip.chomp.casecmp("Hiv") == 0)
        sectors << "HIV/AIDS"
      end
      
      if (sector.strip.chomp.casecmp("Beggars Welfare") == 0) or (sector.strip.chomp.casecmp("Consumer Rights") == 0) or
         (sector.strip.chomp.casecmp("Credit System") == 0) or (sector.strip.chomp.casecmp("Economy") == 0) or 
         (sector.strip.chomp.casecmp("Employment") == 0) or (sector.strip.chomp.casecmp("Unemployment") == 0)
        sectors << "Economic Issues"
      end
      
      if (sector.strip.chomp.casecmp("Adult Education") == 0) or (sector.strip.chomp.casecmp("Book Bank") == 0) or
         (sector.strip.chomp.casecmp("Farmer field Schools") == 0) or (sector.strip.chomp.casecmp("Female Education") == 0) or
         (sector.strip.chomp.casecmp("Industrial School") == 0) or (sector.strip.chomp.casecmp("Library") == 0) or
         (sector.strip.chomp.casecmp("Literacy") == 0) or (sector.strip.chomp.casecmp("Non Formal Education") == 0) or
         (sector.strip.chomp.casecmp("Political Awarness") == 0)or (sector.strip.chomp.casecmp("Welfare of Student") == 0) or 
         (sector.strip.chomp.casecmp("Vocational") == 0) or (sector.strip.chomp.casecmp("Vocational School") == 0) or 
         (sector.strip.chomp.casecmp("Tuition Center") == 0) or (sector.strip.chomp.casecmp("Reading Room") == 0) or 
         (sector.strip.chomp.casecmp("Religious Education") == 0) or (sector.strip.chomp.casecmp("Religious Publications") == 0) or 
         (sector.strip.chomp.casecmp("Research") == 0) or (sector.strip.chomp.casecmp("Risk Reduction training") == 0) or 
         (sector.strip.chomp.casecmp("School") == 0) or (sector.strip.chomp.casecmp("Skill Development") == 0) or
         (sector.strip.chomp.casecmp("Social Education") == 0) or (sector.strip.chomp.casecmp("Technical Education") == 0) or 
         (sector.strip.chomp.casecmp("Training") == 0) or (sector.strip.chomp.casecmp("Training and Education") == 0) or
         (sector.strip.chomp.casecmp("Training and Recruitment of volunteers") == 0) or (sector.strip.chomp.casecmp("Training in Ophthalmologists") == 0)
        sectors << "Education"
      end
      
      if (sector.strip.chomp.casecmp("Aging") == 0) or (sector.strip.chomp.casecmp("Old People Home") == 0) or
         (sector.strip.chomp.casecmp("Welfare of Aged") == 0) or (sector.strip.chomp.casecmp("Senior Citizen") == 0)
        sectors << "Elderly Welfare"
      end
      
      if (sector.strip.chomp.casecmp("Aid Centre") == 0) or (sector.strip.chomp.casecmp("Emergency Relief Services") == 0) or 
         (sector.strip.chomp.casecmp("Emergency Response") == 0)
        sectors << "Emergency Services"
      end
      
      if (sector.strip.chomp.casecmp("Energy") == 0)
        sectors << "Energy Issues"
      end
      
      if (sector.strip.chomp.casecmp("Ecology") == 0) or (sector.strip.chomp.casecmp("Environment") == 0) or
         (sector.strip.chomp.casecmp("Fishermen Welfare") == 0) or (sector.strip.chomp.casecmp("Forest") == 0) or 
         (sector.strip.chomp.casecmp("Sustainable Community") == 0) or (sector.strip.chomp.casecmp("Sustainable Environment") == 0)
        sectors << "Environmental Issues"
      end
      
      if (sector.strip.chomp.casecmp("Aid Centre") == 0) or (sector.strip.chomp.casecmp("Beggars Welfare") == 0) or
         (sector.strip.chomp.casecmp("Clothing") == 0) or (sector.strip.chomp.casecmp("Communication and Media") == 0) or 
         (sector.strip.chomp.casecmp("Community Welfare / Development") == 0) or (sector.strip.chomp.casecmp("Destitute Welfare") == 0) or 
         (sector.strip.chomp.casecmp("Employment") == 0) or (sector.strip.chomp.casecmp("Eradication of poverty through provision of food") == 0) or
         (sector.strip.chomp.casecmp("Fishermen Welfare") == 0) or (sector.strip.chomp.casecmp("General") == 0) or 
         (sector.strip.chomp.casecmp("General Welfare") == 0) or (sector.strip.chomp.casecmp("Industrial Home") == 0) or
         (sector.strip.chomp.casecmp("Industrial Relations") == 0) or (sector.strip.chomp.casecmp("Needy People") == 0) or 
         (sector.strip.chomp.casecmp("Patients Welfare") == 0) or (sector.strip.chomp.casecmp("Poor People Welfare") == 0) or
         (sector.strip.chomp.casecmp("Poor Student Welfare") == 0) or (sector.strip.chomp.casecmp("Population welfare") == 0) or
         (sector.strip.chomp.casecmp("Poverty Allevation") == 0) or (sector.strip.chomp.casecmp("Unemployment") == 0) or 
         (sector.strip.chomp.casecmp("Refugees Facilities") == 0) or (sector.strip.chomp.casecmp("Shelter") == 0) or 
         (sector.strip.chomp.casecmp("Social Welfare") == 0) or (sector.strip.chomp.casecmp("Officers Welfare") == 0)
        sectors << "General Welfare"
      end
      
      if (sector.strip.chomp.casecmp("AIDS") == 0) or (sector.strip.chomp.casecmp("Blood Bank") == 0) or 
         (sector.strip.chomp.casecmp("Clinical Laboratory") == 0) or 
         (sector.strip.chomp.casecmp("Diabetic Patients") == 0) or
         (sector.strip.chomp.casecmp("Disabled Persons") == 0) or 
         (sector.strip.chomp.casecmp("Dispensary") == 0) or 
         (sector.strip.chomp.casecmp("Eye Camp") == 0) or 
         (sector.strip.chomp.casecmp("Eye health and capacity building") == 0) or
         (sector.strip.chomp.casecmp("Family Planning") == 0) or 
         (sector.strip.chomp.casecmp("Healing") == 0) or
         (sector.strip.chomp.casecmp("Health") == 0) or 
         (sector.strip.chomp.casecmp("Hiv") == 0) or
         (sector.strip.chomp.casecmp("MCH Centre") == 0) or 
         (sector.strip.chomp.casecmp("Medical Facilities") == 0) or 
         (sector.strip.chomp.casecmp("Mentally Retarded") == 0)  or 
         (sector.strip.chomp.casecmp("Patients Welfare") == 0) or 
         (sector.strip.chomp.casecmp("Physical and Mentally Handicap") == 0) or 
         (sector.strip.chomp.casecmp("Physically Handicapped") == 0) or
         (sector.strip.chomp.casecmp("Primary Health") == 0) or 
         (sector.strip.chomp.casecmp("Psychological Support") == 0) or 
         (sector.strip.chomp.casecmp("Rehabilitation") == 0) or 
         (sector.strip.chomp.casecmp("Rehabilitation of Disables") == 0) or 
         (sector.strip.chomp.casecmp("Reproductive Health") == 0) or 
         (sector.strip.chomp.casecmp("Stiching Center") == 0) or
         (sector.strip.chomp.casecmp("Supply of Eye Equipments") == 0) or 
         (sector.strip.chomp.casecmp("TB Patients") == 0) or 
         (sector.strip.chomp.casecmp("Training in Ophthalmologists") == 0)
        sectors << "Health"
      end
      
      if (sector.strip.chomp.casecmp("Human Rights") == 0) or (sector.strip.chomp.casecmp("Labour Right") == 0)
        sectors << "Human Rights"
      end
      
      if (sector.strip.chomp.casecmp("Construction") == 0) or (sector.strip.chomp.casecmp("Development Of Village") == 0) or
         (sector.strip.chomp.casecmp("Infrastructure Development") == 0) or (sector.strip.chomp.casecmp("Institution Building") == 0) or 
         (sector.strip.chomp.casecmp("Institution Strengthening") == 0) or (sector.strip.chomp.casecmp("Pavement of Streets") == 0) or 
         (sector.strip.chomp.casecmp("Transport Facilities") == 0) or (sector.strip.chomp.casecmp("Sanitation") == 0) or 
         (sector.strip.chomp.casecmp("Traffic Management") == 0)
        sectors << "Infrastructure"
      end
      
      if (sector.strip.chomp.casecmp("Legal Aid") == 0) or (sector.strip.chomp.casecmp("Legal Assistance") == 0) or
         (sector.strip.chomp.casecmp("Prisoners") == 0)
        sectors << "Legal Services"
      end
      
      if (sector.strip.chomp.casecmp("Book Bank") == 0) or (sector.strip.chomp.casecmp("Library") == 0) or 
         (sector.strip.chomp.casecmp("Literacy") == 0) or (sector.strip.chomp.casecmp("Reading Room") == 0)
        sectors << "Literacy"
      end
      
      if (sector.strip.chomp.casecmp("Drug Abuse") == 0) or (sector.strip.chomp.casecmp("Drug Addicted Rehabilitation") == 0) or
         (sector.strip.chomp.casecmp("Narcotics Control") == 0)
        sectors << "Narcotics Issues"
      end
      
      if (sector.strip.chomp.casecmp("Entertainment") == 0) or (sector.strip.chomp.casecmp("Recreational") == 0) or
         (sector.strip.chomp.casecmp("Sports Facility") == 0)
        sectors << "Recreation"
      end
      
      if (sector.strip.chomp.casecmp("Religious Education") == 0) or (sector.strip.chomp.casecmp("Religious Publications") == 0)
        sectors << "Religious Organizations"
      end
      
      if (sector.strip.chomp.casecmp("Technology") == 0) or (sector.strip.chomp.casecmp("Technical Education") == 0)
        sectors << "Technology"
      end
      
      if (sector.strip.chomp.casecmp("Urban Development") == 0)
        sectors << "Urban Development"
      end
      
      if (sector.strip.chomp.casecmp("Drinking Water") == 0) or (sector.strip.chomp.casecmp("Installation of Hand Pumps") == 0) or
         (sector.strip.chomp.casecmp("Water Supply") == 0)
        sectors << "Water Issues"
      end
      
      if (sector.strip.chomp.casecmp("Family Planning") == 0) or (sector.strip.chomp.casecmp("Female Education") == 0) or
         (sector.strip.chomp.casecmp("Gender") == 0) or (sector.strip.chomp.casecmp("home economic") == 0) or 
         (sector.strip.chomp.casecmp("MCH Centre") == 0) or (sector.strip.chomp.casecmp("Women Empowerment") == 0) or
         (sector.strip.chomp.casecmp("Women Reproductive Health") == 0) or (sector.strip.chomp.casecmp("Women Rights") == 0) or
         (sector.strip.chomp.casecmp("Women Welfare") == 0) or (sector.strip.chomp.casecmp("Reproductive Health") == 0)
        sectors << "Women's Issues"
      end
      
    end # sector_array.each do |sector|
      
  end # end unless item[:sector].nil

  sectors.uniq!

  # pak ngos are not given foreign affiliations
  affiliations = []
  unless item[:affiliation].nil?
      
  end # end unless item[:afilliantion].nil
  
  
  contacts = item[:contacts]
  

  # this is the scraping script for Pakistan, and we know that's where the NGOs are based 
  item[:country] = "Pakistan"

  # if the country for the NGO does not exist, create it
  if Country.exists?(:name => item[:country])
    @country = Country.find_by_name(item[:country]).id
  else
    @country = Country.create(:name => item[:country]).id
  end


  if item[:province].strip.chomp.casecmp("Federal") == 0
    item[:province] = "Islamabad"
  elsif item[:province].strip.chomp.casecmp("Khyber Pakhtoon Khawa") == 0
    item[:province] = "North-West Frontier (Khyber Pakhtunkhwa)"
  elsif item[:province].strip.chomp.casecmp("Balochistan") == 0
    item[:province] = "Baluchistan"
  elsif item[:province].strip.chomp.casecmp("Sindh") == 0
    item[:province] = "Sind"
  elsif item[:province].strip.chomp.casecmp("Azad Jamu  Kashmir") == 0
    item[:province] = "Azad Kashmir"
  elsif item[:province].strip.chomp.casecmp("Gilgit Baltistan") == 0
    item[:province] = "Gilgit-Baltistan (Northern Areas)"
  end
  
  if Province.exists?(:name => item[:province])
    @province = Province.find_by_name(item[:province]).id
  else
    @province = Province.create(:name => item[:province], :country_id => @country).id
  end
  

  # if the district for the NGO does not exist, create it
  if District.exists?(:name => item[:district])
    @district = District.find_by_name(item[:district]).id
  else
    @district = District.create(:name => item[:district], :province_id => @province, :country_id => @country).id
  end

  item[:acronym] = nil if item[:acronym] = ""
  item[:contact_address] = nil if item[:contact_address] = ""
  item[:contact_phone] = nil if item[:contact_phone] = ""
  item[:contact_email] = nil if item[:contact_email] = ""
  item[:contact_fax] = nil if item[:contact_fax] = ""
  item[:website] = nil if item[:website] = ""

  ngo_params = {:acronym => item[:acronym],
                :name => item[:name],
                :contact_address => item[:contact_address],
                :contact_phone => item[:contact_phone],
                :contact_email => item[:contact_email],
                :contact_fax => item[:contact_fax],
                :website => item[:website],
                :district_id => @district,
                :province_id => @province,
                :country_id => @country}


  # check to see if the ngo exists; if not, create it, otherwise, update it (the pak ngos do not seem to have acronyms)
  if Ngo.exists?(:name => item[:name]) #and Ngo.exists?(:acronym => item[:acronym])
    @ngo = Ngo.find(:first, :conditions => ["name = ?", item[:name]])
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
            contact = Contact.create(:name => contact_info[:name]) #, :title => contact_info[:title], :phone => contact_info[:phone], :email => contact_info[:email])
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
    
    if item[:sectors].empty?
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
            @ngo.sectors << current_sector
          end
        end
      end # end sectors loop
    end # end of this if-else block
  end # end if @ngo.auto_update
  
  count += 1

end # end ngo hash each



=begin
other available info that we're not using at this time

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


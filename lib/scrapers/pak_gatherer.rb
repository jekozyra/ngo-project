#!/usr/bin/env ruby

require 'rexml/document'
require 'rubygems'
require 'hpricot'
require 'scrubyt'
require 'open-uri'

$valid_ids = [67,120,153,123,2,99,151,75,78,95,189,133,201,205,152,4,163,200,157,128,79,185,60,57,6,184,8,96,77,88,197,149,111,
              68,83,177,11,119,12,13,14,134,165,52,15,69,17,126,92,131,42,188,73,166,168,187,202,41,36,108,127,20,196,206,21,136,
              158,22,159,180,181,175,178,179,87,195,155,164,76,150,190,146,93,61,82,94,53,62,174,107,186,54,204,35,176,74,63,45,
              198,106,47,115,118,27,122,100,154,109,40,48,56,173,58,160,132,29,182,193,194,30,113,91,124,129,38,39,59,104,192,137,
              135,203,112,70,31,32,156,130,121,138,65,199,72,125,49,161,55,148,44,43,147,191,117,162,33,98,34]

$Ngo_sectors = "Adult Education (67) - 271 entries
                Advocacy (120) - 56 entries
                Advocacy and Awareness (153) - 107 entries
                Aging (123) - 2 entries
                Agriculture (2) - 156 entries
                Aid Centre (99) - 25 entries
                AIDS (151) - 42 entries
                Beggars Welfare (75) - 58 entries
                Blood Bank (78) - 45 entries
                Book Bank (95) - 17 entries
                Burning issues (189) - 3 entries
                Capacity Building (133) - 68 entries
                Child labour (201) - 10 entries
                Child Protection (205) - 3 entries
                Child Sex Abuse (152) - 18 entries
                Child Welfare (4) - 3117 entries
                Children Rights (163) - 66 entries
                Civil Deffence (200) - 1 entries [REDUNDANT, IGNORE]
                Clinical Laboratory (157) - 8 entries
                Clothing (128) - 7 entries
                Co ordination (79) - 51 entries
                Communication and Media (185) - 14 entries
                Community Welfare / Development (60) - 665 entries
                Construction (57) - 30 entries
                Consumer Rights (6) - 8 entries
                Credit System (184) - 4 entries
                Culture (8) - 67 entries
                Day Care Centre (96) - 7 entries
                Deaf and Dumb (77) - 24 entries
                Destitute Welfare (88) - 40 entries
                Detoxification (197) - 3 entries
                Development Of Village (149) - 33 entries
                Diabetic Patients (111) - 4 entries
                Disabled Persons (68) -214 entries
                Dispensary (83) - 167 entries
                Drinking Water (177) - 32 entries
                Drug Abuse(11) - 113 entries
                Drug Addicted Rehabilitation (119) - 10 entries
                Ecology (12) - 15 entries
                Economy (13) - 49 entries
                Education (14) - 30259 entries
                Emergency Relief Services (134) - 24 entries
                Emergency Response (165) - 9 entries
                Employmentn (52) - 20 entries
                Energy (15) - 4 entries
                Entertainment (69) - 22 entries
                Environment (17) - 272 entries
                Eradication of poverty through provision of food (126) - 7 entries
                Eye Camp (92) - 26 entries
                Eye health and capacity building (131) - 5 entries
                Family Planning (42) - 194 entries
                Farmer field Schools (188) - 8 entries
                Female Education (73) - 44 entries
                Fish Farm (166) - 0 entries [IGNORE, NO ENTRIES]
                Fishermen Welfare (168) - 2 entries
                Forest (187) - 3 entries
                Gender (202) - 10 entries
                General (42) - 37 entries
                General Welfare (36) - 760 entries
                Handicapped Welfare (108) - 233 entries
                Healing (127) - 4 entries
                Health (20) - 29068 entries
                Hiv (196) - 6 entries
                home economic (206) - 0 entries [IGNORE]
                Human Rights (21) - 199 entries
                Humanitarian Development (136) - 17 entries
                Industrial Home (158) - 170 entries
                Industrial Relations (22) - 799 entries
                Industrial School (159) - 2 entries [IGNORE, REDUNDANT]
                Information Dissemination (180) - 12 entries
                Infrastructure Development (181) - 10 entries
                Installation of Hand Pumps (175) - 8 entries
                Institution Building (178) - 14 entries
                Institution Strengthening (179) - 8 entries
                Juvenile Delinquents Welfare (87) - 7 entries
                Labour Right (195) - 4 entries
                Legal Aid (155) - 26 entries
                Legal Assistance (164) - 9 entries
                Library (76) - 96 entries
                Literacy (150) - 32 entries
                LIVESTOCK (190) - 6 entries
                Local (146) - 2 entries [IGNORE, REDUNDANT]
                MCH Centre (93) - 36 entries
                Medical Facilities (61) - 213 entries
                Mentally Retarded (82) - 17 entries
                Multipurpose (94) - 12 entries
                Narcotics Control (53) - 47 entries
                Needy People (62) - 110 entries
                Non Formal Education (174) - 23 entries
                Officers Welfare (107) - 7 entries
                Old People Home (186) - 1 entries
                Orphans (54) - 55 entries
                Others (204) - 3 entries
                Patients Welfare (35) - 1345 entries
                Pavement of Streets (176) - 3 entries
                Peace (74) - 19 entries
                Physical and Mentally Handicap (63) - 74 entries
                Physically Handicapped (45) - 121 entries
                Political Awarness (198) - 5 entries
                Poor People Welfare (106) - 126 entries
                Poor Student Welfare (47) - 132 entries
                Population welfare (115) - 9 entries
                Population welfare (118) - 4 entries
                Poverty Allevation (27) - 150 entries
                Primary Health (122) - 19 entries
                Prisoners (100) - 29 entries
                Psychological Support (154) - 7 entries
                Reading Room (109) - 7 entries
                Recreational (40) - 531 entries
                Refugees Facilities (48) - 3 entries
                Rehabilitation (56) - 179 entries
                Rehabilitation of Disables (173) - 7 entries
                Religious Education (58) - 185 entries
                Religious Publications (160) - 3 entries
                Reproductive Health (132) - 17 entries
                Research (29) - 51 entries
                Resource Management (182) - 2 entries
                Risk Reduction training (193) - 2 entries
                Risk Reduction training (194) - 3 entries
                Rural Development (30) - 97 entries
                Sanitation (113) - 59 entries
                School (91) - 151 entries
                Senior Citizen (124) - 6 entries
                Shelter (129) - 7 entries
                Skill Development (38) - 35 entries
                Social Education (39) - 1064 entries
                Social Welfare (59) - 372 entries
                Sports Facility (104) - 137 entries
                Stiching Center (192) - 1 entries
                Supply of Eye Equipments (137) - 0 entries [IGNORE]
                Sustainable Community (135) - 14 entries
                Sustainable Environment (203) - 2 entries
                TB Patients (112) - 23 entries
                Technical Education (70) - 52 entries
                Technology (31) - 22 entries
                Traffic Management (32) - 0 entries [IGNORE]
                Training (156) - 44 entries
                Training and Education (130) - 27 entries
                Training and Recruitment of volunteers (121) - 9 entries
                Training in Ophthalmologists (138) - 1 entries
                Transport Facilities (65) - 3 entries
                Tution Center (199) - 4 entries
                Unemployment (72) - 12 entries
                Urban Development (125) - 8 entries
                Vocational (49) - 350 entries
                Vocational School (161) - 39 entries
                Water Supply (55) - 92 entries
                Welfare Of Aged (148) - 8 entries
                Welfare of Blinds (44) - 42 entries
                Welfare of Deaf (43) - 9 entries
                Welfare Of Student (147) - 9 entries
                Women Empowerment (191) - 19 entries
                Women Reproductive Health (117) - 25 entries
                Women Rights (162) - 100 entries
                Women Welfare (33) - 23550 entries
                Youngster Welfare (98) - 19 entries
                Youth Welfare (34) - 3279 entries"

def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end

def get_file_as_array(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data.split(",")
end

def scrape(mode)

  pak_data = Scrubyt::Extractor.define :agent => :firefox do
 
    mode == "all" ? url = "http://www.ngosinfo.gov.pk/SearchResults.aspx?name=&foa=0" : url = "http://www.ngosinfo.gov.pk/SearchResults.aspx?name=&foa=#{mode}"
    fetch url

    result "/html" do
      result_body "/body", :type => :html_subtree
    end

    next_page 'Next' #, :limit => 10
  end
  
  return pak_data
  
end



if __FILE__ == $0
    
  invalid_option = true
  puts "#{$Ngo_sectors}\nChoose an option from the list or type all."
  id = 0
  
  while invalid_option
    
    option = gets
    option.strip!.chomp!
  
    if option.to_i == 0
      if option == "all"
        mode = option
        invalid_option = false
      end
    else
      if $valid_ids.include?(option.to_i)
        invalid_option = false
        mode = option.to_i
      end
    end
    
    if invalid_option
      puts "Please re-enter a valid option."
    end
    
  end

  pak_data = scrape(mode)
  
  puts "DONE SCRAPING, WRITING DATA..."

  File.open("../data/pak_data_xml", 'w') {|f| f.write(pak_data.to_xml) }

  result_string = Hpricot(get_file_as_string("../data/pak_data_xml"))

  result_string.search("//result/result_body/") do |text|
    File.open("../data/pak_data_parsed", 'a') {|f| f.write(text) }
  end

  parsed_page = result_string = Hpricot(get_file_as_string("../data/pak_data_parsed"))

  id_array = get_file_as_array("../data/pak_data_id_file")

#  File.truncate("../data/pak_data_id_file", 0)
  parsed_page.search("a.NgoSearch") do |text|
    id_array << text.attributes['onclick'].split(",")[1].to_i
  end
  
  id_array.uniq!
  
  id_array.each do |id|
    File.open("../data/pak_data_id_file", 'a') {|f| f.write("#{id},") }
  end
  
  File.delete("../data/pak_data_xml", "../data/pak_data_parsed")

end


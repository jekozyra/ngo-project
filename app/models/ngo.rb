class Ngo < ActiveRecord::Base
  
  belongs_to :country
  belongs_to :province
  belongs_to :district
  has_and_belongs_to_many :affiliations
  has_and_belongs_to_many :sectors
  has_and_belongs_to_many :contacts
  
  # this is used for the full text searching
  define_index do
    indexes :acronym
    indexes :name
    indexes country(:name), :as => :country_name
    indexes province(:name), :as => :province_name
    indexes district(:name), :as => :district_name
    indexes affiliations(:name), :as => :affiliation_name
    indexes sectors(:name), :as => :sector_name
    
    has country_id
    has province_id
    has district_id
    
    set_property :field_weights => {
      :name => 10,
      :sector_name    => 5,
      :country_name => 2,
      :province_name => 2,
      :district_name => 2
    }
    
  end
  
  def show_acronym
    self.acronym.nil? ? "---" : self.acronym
  end
  
  def show_name
    self.name.nil? ? "---" : self.name
  end
  
  def show_name_and_acronym
    name_and_acronym = ""
    name_and_acronym += self.name unless self.name.nil?
    name_and_acronym += " (#{self.acronym})" unless self.acronym.nil?
    name_and_acronym
  end
  
  def show_country
    if self.district_id.nil?
      "---"
    else
      if self.district.country_id.nil?
        "---"
      else
        self.district.show_country
      end
    end
  end
  
  def show_province
    self.province_id.nil? ? "---" : self.province.name
  end
  
  def show_district
    self.district_id.nil? ? "---" : self.district.name
  end

  def show_contact_address
    self.contact_address.nil? ? "---" : self.contact_address
  end
  
  def show_contact_phone
    self.contact_phone.nil? ? "---" : self.contact_phone
  end
  
  def show_contact_fax
    self.contact_fax.nil? ? "---" : self.contact_fax
  end
  
  def show_contact_email
    self.contact_email.nil? ? "---" : self.contact_email
  end

  def show_website
    self.website.nil? ? "---" : self.website
  end

  def show_sectors
    if self.sectors.nil? or self.sectors.size == 0
      "---"
    else
      names = ""
      self.sectors.each do |sector|
        names += sector.name
        unless sector == self.sectors.last
          names += ", "
        end
      end
      names
    end
  end
  
  def show_affiliations
    if self.affiliations.nil? or self.affiliations.size == 0
      "---"
    else
      names = ""
      self.affiliations.each do |affiliation|
        names += affiliation.name
        unless affiliation == self.affiliations.last
          names += ", "
        end
      end
      names
    end
  end
  
  def auto_update_value
    if self.auto_update
      "Yes"
    else
      "No"
    end
  end
  
  def has_contact?(contact)
    has_contact = false
    self.contacts.each do |ngo_contact|
      has_contact = true if ngo_contact.id == contact.id
    end
    has_contact
  end
  
  def find_contact?(name)
    contact_ids = Contact.find(:all, :conditions => ["name = ?", name]).map{|contact| contact.id }
    has_contact = false
    contact_ids.each do |contact_id|
      has_contact = true if self.contacts.map{|contact| contact.id}.include?(contact_id)
    end
    has_contact
  end
  
end

class Ngo < ActiveRecord::Base
  
  belongs_to :country
  belongs_to :district
  has_and_belongs_to_many :affiliations
  has_and_belongs_to_many :sectors
  
  
  def show_acronym
    self.acronym.nil? ? "---" : self.acronym
  end
  
  def show_name
    self.name.nil? ? "---" : self.name
  end
  
  def show_country
    self.country_id.nil? ? "---" : self.country.name
  end
  
  def show_district
    self.district_id.nil? ? "---" : self.district.name
  end
  
  def show_contact_name
    self.contact_name.nil? ? "---" : self.contact_name
  end
  
  def show_contact_position
    self.contact_position.nil? ? "---" : self.contact_position
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
  
end

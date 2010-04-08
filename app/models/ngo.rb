class Ngo < ActiveRecord::Base
  
  belongs_to :country
  belongs_to :district
  has_and_belongs_to_many :affiliations
  has_and_belongs_to_many :sectors
  
  def country_name
    if self.country_id.nil?
      "---"
    else
      self.country.name
    end
  end
  
  def district_name
    if self.district_id.nil?
      "---"
    else
      self.district.name
    end
  end
  
  def affiliation_name
    if self.affiliation_id.nil?
      "---"
    else
      self.affiliation.name
    end
  end
  
  def sector_name
    if self.sector_id.nil?
      "---"
    else
      self.sector.name
    end
  end
  
  def sector_names
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
  
  def affiliation_names
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

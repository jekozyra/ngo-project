class District < ActiveRecord::Base
  belongs_to :country
  belongs_to :province
  has_many :ngos
  
  def show_province
    self.province.nil? ? "---" : self.province.name
  end
  
  def show_country
    self.country.nil? ? "---" : self.country.name
  end
  
end

class Province < ActiveRecord::Base
  belongs_to :country
  has_many :ngos
  
  def show_country
    self.country.nil? ? "---" : self.country.name
  end
  
end

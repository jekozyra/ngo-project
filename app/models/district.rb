class District < ActiveRecord::Base
  belongs_to :country
  belongs_to :province
  has_many :ngos
end

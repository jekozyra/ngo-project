class District < ActiveRecord::Base
  belongs_to :country
  has_many :ngos
end

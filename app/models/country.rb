class Country < ActiveRecord::Base
  has_many :districts
  has_many :ngos
end

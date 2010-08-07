class Sector < ActiveRecord::Base
  has_and_belongs_to_many :ngos
  validates_uniqueness_of :name

end

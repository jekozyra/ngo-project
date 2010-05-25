class AddGeographicDataForDistricts < ActiveRecord::Migration
  def self.up
    add_column :districts, :latlong, :string
  end

  def self.down
    remove_column :districts, :latlong
  end
end

class UpdateDistrictFieldsToJiveWithProvinces < ActiveRecord::Migration
  def self.up
    add_column :ngos, :province_id, :integer
    add_column :districts, :province_id, :integer
    remove_column :districts, :iso_code
  end

  def self.down
    remove_column :ngos, :province_id
    remove_column :districts, :province_id
    add_column :districts, :iso_code, :string
  end
end

class AddAutoUpdateFieldsForNgo < ActiveRecord::Migration
  def self.up
    add_column :ngos, :auto_update_country, :boolean, :default => 1
    add_column :ngos, :auto_update_province, :boolean, :default => 1
    add_column :ngos, :auto_update_district, :boolean, :default => 1
    add_column :ngos, :auto_update_sectors, :boolean, :default => 1
    add_column :ngos, :auto_update_contact_address, :boolean, :default => 1
    add_column :ngos, :auto_update_contact_phone, :boolean, :default => 1
    add_column :ngos, :auto_update_contact_fax, :boolean, :default => 1
    add_column :ngos, :auto_update_contact_email, :boolean, :default => 1
    add_column :ngos, :auto_update_website, :boolean, :default => 1
    add_column :ngos, :auto_update_affiliation, :boolean, :default => 1
  end

  def self.down
    remove_column :ngos, :auto_update_country
    remove_column :ngos, :auto_update_province
    remove_column :ngos, :auto_update_district
    remove_column :ngos, :auto_update_sectors
    remove_column :ngos, :auto_update_contact_address
    remove_column :ngos, :auto_update_contact_phone
    remove_column :ngos, :auto_update_contact_fax
    remove_column :ngos, :auto_update_contact_email
    remove_column :ngos, :auto_update_website
    remove_column :ngos, :auto_update_affiliation
  end
end

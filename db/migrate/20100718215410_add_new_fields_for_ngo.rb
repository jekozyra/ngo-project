class AddNewFieldsForNgo < ActiveRecord::Migration
  # office fax, url
  
  def self.up
    add_column :ngos, :contact_fax, :string
    add_column :ngos, :website, :string
  end

  def self.down
    remove_column :ngos, :contact_fax
    remove_column :ngos, :website
  end
end

class RemoveContactNameFieldFromNgo < ActiveRecord::Migration
  def self.up
    remove_column :ngos, :contact_name
    remove_column :ngos, :contact_position
  end

  def self.down
    add_column :ngos, :contact_name, :string
    add_column :ngos, :contact_position, :string
  end
end

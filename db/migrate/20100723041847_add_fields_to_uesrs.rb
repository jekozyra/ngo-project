class AddFieldsToUesrs < ActiveRecord::Migration
  def self.up
    add_column :users, :who, :string
    add_column :users, :how, :text
  end

  def self.down
    remove_column :users, :who
    remove_column :users, :how
  end
end

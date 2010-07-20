class AddJoinTableForContactsNgos < ActiveRecord::Migration
  def self.up
    create_table :contacts_ngos, {:id => false} do |t|
      t.integer :contact_id
      t.integer :ngo_id
    end    
  end

  def self.down
    drop_table :contacts_ngos
  end
end

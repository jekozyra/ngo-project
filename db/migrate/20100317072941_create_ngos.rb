class CreateNgos < ActiveRecord::Migration
  def self.up
    create_table :ngos do |t|
      t.string :acronym
      t.string :name
      t.integer :country_id
      t.integer :district_id
      t.string :contact_name
      t.string :contact_position
      t.string :contact_address
      t.string :contact_phone
      t.string :contact_email
      t.boolean :auto_update, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :ngos
  end
end

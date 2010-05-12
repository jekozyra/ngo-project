class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :hashed_password
      t.string :salt
      t.string :user_type
      t.boolean :approved, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

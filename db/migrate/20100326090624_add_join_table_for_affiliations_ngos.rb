class AddJoinTableForAffiliationsNgos < ActiveRecord::Migration
  def self.up
    create_table :affiliations_ngos, {:id => false} do |t|
      t.integer :ngo_id
      t.integer :affiliation_id
    end    
  end

  def self.down
    drop_table :affiliations_ngos
  end
end

class CreateJoinTableForSectorsAndNgos < ActiveRecord::Migration
  def self.up
    
    create_table :ngos_sectors, {:id => false} do |t|
      t.integer :ngo_id
      t.integer :sector_id
    end    
  end

  def self.down
    drop_table :ngos_sectors
  end
end

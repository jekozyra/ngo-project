class AddIsoCodeForDistrict < ActiveRecord::Migration
    def self.up
      add_column :districts, :iso_code, :string
    end

    def self.down
      remove_column :districts, :iso_code
    end
  end


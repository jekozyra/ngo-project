class DataFile < ActiveRecord::Base
  
  def self.columns() @columns ||= []; end
 
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
 
  column :filename, :string
  column :data, :text
  column :table_name, :string
  column :file_type, :string

#  validates_format_of :filename, :with => %r{\.txt$}i, :message => "- File format must be text (.txt)"
  
  
end

class DirectoryController < ApplicationController
  
  layout 'main_layout'
    
  def about
    @total_ngos = Ngo.count(:id, :distinct => 'true')
    @total_countries = Ngo.count(:country_id, :distinct => 'true')
    @total_provinces = Ngo.count(:province_id, :distinct => 'true')
    @total_districts = Ngo.count(:district_id, :distinct => 'true')
  end
  
  def stats
    @total_ngos = Ngo.count(:id, :distinct => 'true')
    @total_countries = Ngo.count(:country_id, :distinct => 'true')
    @total_provinces = Ngo.count(:province_id, :distinct => 'true')
    @total_districts = Ngo.count(:district_id, :distinct => 'true')
    
    countries = Ngo.find(:all, :select => "distinct country_id").map{|ngo| ngo.country_id}
    @countries_ngos = []
    
    countries.each do |country|
      total_ngos = Ngo.count(:id, :distinct => 'true', :conditions => ["country_id = ?", country])
      country_name = Country.find(country).name
      
      @countries_ngos << {:chart_label => country_name, :chart_number => total_ngos}
      
    end
    
    my_file = File.open("#{RAILS_ROOT}/public/data/stats.json", File::WRONLY|File::TRUNC|File::CREAT)
    my_file.puts "{\"stats\":" + @countries_ngos.to_json.to_s + ",\"chart_title\": \"By Country\"}"
    my_file.close
    
    render :layout => "vis_layout"
  end

end

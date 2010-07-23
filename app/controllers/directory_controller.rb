class DirectoryController < ApplicationController
  
  layout 'main_layout'
    
  def about
    @total_ngos = Ngo.count(:id, :distinct => 'true')
    @total_countries = Ngo.count(:country_id, :distinct => 'true')
    @total_provinces = Ngo.count(:province_id, :distinct => 'true')
    @total_districts = Ngo.count(:district_id, :distinct => 'true')
  end
  
  def stats
    
    @charts = {:entries => []}
    
    # get the ngos per country
    countries = Ngo.find(:all, :select => "distinct country_id").map{|ngo| ngo.country_id}
    countries_ngos = []
    countries.each do |country|
      total_ngos = Ngo.count(:id, :distinct => 'true', :conditions => ["country_id = ?", country])
      country_name = Country.find(country).name
      countries_ngos << {:chart_label => country_name, :chart_number => total_ngos}
    end
    country_chart = {:stats => countries_ngos,
                      :chart_title => "NGOs in the database by country",
                      :chart_div => "chart_div_country",
                      :column_label => "Country",
                      :numeric_label => "Number of Entries"}
    
    @charts[:entries] << country_chart

    
    # get the ngos per sector
    sectors = Sector.all
    sectors_ngos = []
    sectors.each do |sector|
      total_ngos = Ngo.count_by_sql("SELECT COUNT(distinct ngo_id) FROM ngos_sectors WHERE sector_id = #{sector.id}")
      sector_name = sector.name
      sectors_ngos << {:chart_label => sector_name, :chart_number => total_ngos}
    end
    sector_chart = {:stats => sectors_ngos,
                    :chart_title => "NGOs in the database by sector",
                    :chart_div => "chart_div_sector",
                    :column_label => "Sector",
                    :numeric_label => "Number of Entries"}
    
    @charts[:entries] << sector_chart
    
    # get the ngos per province per country
    @countries = Country.find(:all, :conditions => ["id in (?)", countries], :order => "name")
    @countries.each do |country|
      provinces = Province.find(:all, :conditions => ["country_id = ?", country.id])
      provinces_ngos = []
      provinces.each do |province|
        total_ngos = Ngo.count(:id, :distinct => true, :conditions => ["province_id = ?", province.id])
        provinces_ngos << {:chart_label => province.name, :chart_number => total_ngos}
      end
      
      province_chart = {:stats => provinces_ngos,
                        :chart_title => "NGOs of #{country.name} by province",
                        :chart_div => "chart_div_#{country.name}",
                        :column_label => "Province",
                        :numeric_label => "Number of Entries"}
                        
      @charts[:entries] << province_chart
      
    end # end @countries.each
    
    
    
    my_file = File.open("#{RAILS_ROOT}/public/data/stats.json", File::WRONLY|File::TRUNC|File::CREAT)
    my_file.puts @charts.to_json.to_s
    my_file.close
    
    render :layout => "stats_layout"
  end


end

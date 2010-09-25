class AnalyzeController < ApplicationController
  
  layout 'main_layout'
  
  def index
    @chart_type = "Pie chart"
    @xdata_constraints = []
    @country_constraints = Country.find(:all, :order => :name)
    @province_constraints = Province.find(:all, :order => :name)
    @district_constraints = District.find(:all, :order => :name)
    @sector_constraints = Sector.find(:all, :order => :name)
  end
  
  
  def save_image
    @image_src = params[:image_link]
  end
  

  def build_visualization

    #@charts = {:entries => []}
    
    params[:chart][:country_constraints].nil? ? country_constraints = Country.all.collect{|country| country.id } : country_constraints = params[:chart][:country_constraints]
    params[:chart][:province_constraints].nil? ? province_constraints = Province.all.collect{|province| province.id} : province_constraints = params[:chart][:province_constraints]
    params[:chart][:district_constraints].nil? ? district_constraints = District.all.collect{|district| district.id} : district_constraints = params[:chart][:district_constraints]
    params[:chart][:sector_constraints].nil? ? sector_constraints = Sector.all.collect{|sector| sector.id} : sector_constraints = params[:chart][:sector_constraints]
    @chart_type = params[:chart][:type]
    chart_xdata = params[:chart][:xdata]
    chart_ydata = params[:chart][:ydata]
    chart_title = params[:chart][:title]
    
    if chart_ydata.nil?
      @charts = one_axis(chart_title, country_constraints, province_constraints, district_constraints, sector_constraints, @chart_type, chart_xdata)
    else
      @charts = two_axis(chart_title, country_constraints, province_constraints, district_constraints, sector_constraints, @chart_type, chart_xdata, chart_ydata)
    end
    
    my_file = File.open("#{RAILS_ROOT}/public/data/stats.json", File::WRONLY|File::TRUNC|File::CREAT)
    my_file.puts @charts.to_json.to_s
    my_file.close
    
    available_colors = ["3366cc","dc3912","ff9900","109618","990099","0099c6","dd4477","66aa00","b82e2e",
                         "316395","994499","22aa99","aaaa11","6633cc","e67300","8b0707","651067","329262",
                         "5574a6","3b3eac","b77322","16d620","b91383","f4359e","9c5935"]

    if @chart_type == "Pie chart"
      data_length =  @charts[:entries].first[:stats].size
      total_ngos = 0
      @charts[:entries].first[:stats].each{|num| total_ngos += num[1]}
      chart_labels = @charts[:entries].first[:stats].collect{|datum| "#{datum[0]} (#{sprintf('%.1f', datum[1].to_f/total_ngos.to_f*100)}%)"}.join("|")
      chart_dataset = @charts[:entries].first[:stats].collect{|datum| datum[1].to_f/total_ngos.to_f*100}.join(",")
      
      @download_link = "http://chart.apis.google.com/chart?chs=600x500&cht=p&chd=t:#{chart_dataset}&chdl=#{chart_labels}&chp=4.72&chco=#{available_colors[0..data_length-1].join(',')}"
    elsif @chart_type == "Horizonal bar chart"
    elsif @chart_type == "Vertical bar chart"
      data_length =  @charts[:entries].first[:stats].size
      chart_labels = @charts[:entries].first[:stats].collect{|datum| "#{datum[0]}"}.join("|")
      chart_dataset = @charts[:entries].first[:stats].collect{|datum| datum[1..datum.length-1].join(",")}.join("|")
      xmax = 10
      @charts[:entries].first[:stats].each do |datum|
        xmax = datum[1..datum.length-1].max if datum[1..datum.length-1].max > xmax
      end
      
      @download_link = "http://chart.apis.google.com/chart?chxt=y&chbh=a&chs=600x500&cht=bvg&chco=#{available_colors[0..data_length-1].join(',')}&chdl=#{chart_labels}&chd=t:#{chart_dataset}&chtt=#{chart_title}"
      
      #http://chart.apis.google.com/chart?chxt=y&chbh=a&chs=300x225&cht=bvg&chco=A2C180,3D7930&chd=t:10,50,60,80,40,60,30|50,60,100,40,20,40,30&chtt=Vertical+bar+chart
    end
    
    render :layout => 'analyze_layout'
    
  end
  
  
  
  def one_axis(chart_title, country_constraints, province_constraints, district_constraints, sector_constraints, chart_type, chart_xdata)
    
    charts = {:entries => []}
    
    country_string = country_constraints.join(",")
    province_string = province_constraints.join(",")
    district_string = district_constraints.join(",")
    
    if chart_xdata == "Countries"
      # get the ngos per country
      countries = Ngo.find(:all, :select => "distinct country_id", :conditions => ["country_id in (?)", country_constraints]).map{|ngo| ngo.country_id}

      countries_ngos = []
      countries.each do |country|
        
        total_ngos = []
        unless sector_constraints.nil?
          total_ngos = Ngo.count_by_sql("SELECT count(distinct ngos.id) FROM ngos, ngos_sectors 
                                         WHERE ngos.country_id = #{country}
                                         AND ngos.province_id IN (#{province_string}) 
                                         AND ngos.district_id IN (#{district_string}) 
                                         AND ngos.id = ngos_sectors.ngo_id 
                                         AND ngos_sectors.sector_id IN (#{sector_constraints.join(",")})")
        else
          total_ngos = Ngo.count(:id, :distinct => 'true', :conditions => ["country_id = ? AND province_id in (?) AND district_id IN (?)", country, province_constraints, district_constraints])
        end
        #total_ngos = Ngo.count(:id, :distinct => 'true', :conditions => ["country_id = ? and p", country])
        country_name = Country.find(country).name
        countries_ngos << [country_name, total_ngos]
      end
      country_chart = {:stats => countries_ngos,
                        :chart_title => chart_title,
                        :chart_div => "chart_div",
                        :column_label => "Country",
                        :numeric_label => "NGOs",
                        :chart_type => chart_type}
    
      charts[:entries] << country_chart
    elsif chart_xdata == "Provinces"
      # get the ngos per country
      provinces = Ngo.find(:all, 
                           :select => "distinct province_id", 
                           :conditions => ["country_id in (?) and province_id in (?) and district_id in (?)", country_constraints, province_constraints, district_constraints]).map{|ngo| ngo.province_id}
      provinces_ngos = []
      provinces.each do |province|
        
        total_ngos = []
         unless sector_constraints.nil?
           total_ngos = Ngo.count_by_sql("SELECT count(distinct ngos.id) FROM ngos, ngos_sectors 
                                          WHERE ngos.province_id = #{province}
                                          AND ngos.country_id IN (#{country_string}) 
                                          AND ngos.district_id IN (#{district_string}) 
                                          AND ngos.id = ngos_sectors.ngo_id 
                                          AND ngos_sectors.sector_id IN (#{sector_constraints.join(",")})")
         else
           total_ngos = Ngo.count(:id, :distinct => 'true', :conditions => ["province_id = ? AND country_id in (?) AND district_id IN (?)", province, country_constraints, district_constraints])
         end
        
        province_name = Province.find(province).name
        provinces_ngos << [province_name, total_ngos]
      end
      province_chart = {:stats => provinces_ngos,
                        :chart_title => chart_title,
                        :chart_div => "chart_div",
                        :column_label => "Province",
                        :numeric_label => "NGOs",
                        :chart_type => chart_type}
    
      charts[:entries] << province_chart
    elsif chart_xdata == "Districts"
      # get the ngos per district
      districts = Ngo.find(:all, 
                           :select => "distinct district_id", 
                           :conditions => ["country_id in (?) and province_id in (?) and district_id in (?)", country_constraints, province_constraints, district_constraints]).map{|ngo| ngo.district_id}
      districts_ngos = []
      districts.each do |district|
        
        total_ngos = []
         unless sector_constraints.nil?
           total_ngos = Ngo.count_by_sql("SELECT count(distinct ngos.id) FROM ngos, ngos_sectors 
                                          WHERE ngos.district_id = #{district}
                                          AND ngos.province_id IN (#{province_string}) 
                                          AND ngos.country_id IN (#{country_string}) 
                                          AND ngos.id = ngos_sectors.ngo_id 
                                          AND ngos_sectors.sector_id IN (#{sector_constraints.join(",")})")
         else
           total_ngos = Ngo.count(:id, :distinct => 'true', :conditions => ["district_id = ? AND province_id in (?) AND country_id IN (?)", district, province_constraints, country_constraints])
         end
        
        district_name = District.find(district).name
        districts_ngos << [district_name, total_ngos]
      end
      district_chart = {:stats => districts_ngos,
                        :chart_title => chart_title,
                        :chart_div => "chart_div",
                        :column_label => "District",
                        :numeric_label => "NGOs",
                        :chart_type => chart_type}
    
      charts[:entries] << district_chart
      
    elsif chart_xdata == "Sectors"
      
      sectors = []
      if sector_constraints.nil?
        sectors = Sector.find(:all, :order => :name)
      else
        sectors = Sector.find(:all, :conditions => ["id IN (?)", sector_constraints], :order => :name)
      end
      
      country_constraints_string = country_constraints.join(",")
      province_constraints_string = province_constraints.join(",")
      district_constraints_string = district_constraints.join(",")

      sectors_ngos = []
      sectors.each do |sector|
        total_ngos = Ngo.count_by_sql("SELECT COUNT(distinct ngos_sectors.ngo_id) FROM ngos, ngos_sectors 
                                       WHERE ngos.id = ngos_sectors.ngo_id 
                                       AND ngos_sectors.sector_id = #{sector.id} 
                                       AND ngos.country_id IN (#{country_constraints_string}) 
                                       AND ngos.province_id IN (#{province_constraints_string}) 
                                       AND ngos.district_id IN (#{district_constraints_string})")
        sectors_ngos << [sector.name, total_ngos]
      end
      
      sector_chart = {:stats => sectors_ngos,
                      :chart_title => chart_title,
                      :chart_div => "chart_div",
                      :column_label => "Sector",
                      :numeric_label => "NGOs",
                      :chart_type => chart_type}
    
      charts[:entries] << sector_chart  
    end
    
    return charts
  end
  
  
  
  def two_axis(chart_title, country_constraints, province_constraints, district_constraints, sector_constraints, chart_type, chart_xdata, chart_ydata)
        
    charts = {:entries => []}
    
    sectors_chart = {:stats => [],
                     :chart_title => chart_title,
                     :chart_div => "chart_div",
                     :column_label => chart_ydata,
                     :numeric_label => "NGOs",
                     :axis_labels => [],
                     :chart_type => chart_type}
    
    
    # gather up the sectors that meet the conditions
    sectors = Sector.find(:all, :conditions => ["id in (?)", sector_constraints], :order => :name)
    sectors_chart[:axis_labels] = sectors.map{|sector| sector.name}
    
    # collect all of the ngos that meet the geographic conditions
    ngos = Ngo.find(:all,
                    :conditions => ["ngos.country_id in (?) and ngos.province_id in (?) and ngos.district_id in (?)", country_constraints, province_constraints, district_constraints])

    # compare sectors across countries
    if chart_ydata == "Countries"
      countries = ngos.map{|ngo| ngo.country_id}.uniq
      
      # loop over the available countries and get the ngos per sector for that country
      countries.each do |country|
        
        sectors_ngos = [Country.find(country).name]
        
        sectors.each do |sector|
          sectors_ngos << Ngo.count_by_sql("SELECT COUNT(DISTINCT ngos_sectors.ngo_id) FROM ngos_sectors, ngos WHERE ngos_sectors.sector_id = #{sector.id} and ngos.id = ngos_sectors.ngo_id and ngos.country_id = #{country}")
        end
        
        sectors_chart[:stats] << sectors_ngos
      end
        
    elsif chart_ydata == "Provinces"
      provinces = ngos.map{|ngo| ngo.province_id}.uniq
      
      # loop over the available countries and get the ngos per sector for that country
      provinces.each do |province|
        
        sectors_ngos = [Province.find(province).name]
        
        sectors.each do |sector|
          sectors_ngos << Ngo.count_by_sql("SELECT COUNT(DISTINCT ngos_sectors.ngo_id) FROM ngos_sectors, ngos WHERE ngos_sectors.sector_id = #{sector.id} and ngos.id = ngos_sectors.ngo_id and ngos.province_id = #{province}")
        end
        
        sectors_chart[:stats] << sectors_ngos
      end        

    elsif chart_ydata == "Districts"
      districts = ngos.map{|ngo| ngo.district_id}.uniq
      
      # loop over the available countries and get the ngos per sector for that country
      districts.each do |district|
        
        sectors_ngos = [District.find(district).name]
        
        sectors.each do |sector|
          sectors_ngos << Ngo.count_by_sql("SELECT COUNT(DISTINCT ngos_sectors.ngo_id) FROM ngos_sectors, ngos WHERE ngos_sectors.sector_id = #{sector.id} and ngos.id = ngos_sectors.ngo_id and ngos.district_id = #{district}")
        end
        
        sectors_chart[:stats] << sectors_ngos
      end      
      
    end
    
    charts[:entries] << sectors_chart
    
    return charts
  end


  def update_chart_type_image
    render :partial => "step_one", :locals => {:chart_type => params[:chart_type]}
  end
  
  def update_second_step_info
    render :partial => "step_two", :locals => {:chart_type => params[:chart_type]}
  end
  
  def update_third_step_countries

  end
  
  def update_third_step_provinces
    @province_constraints = Province.find(:all, :conditions => ["country_id IN (?)", params[:chart_country_constraints].split(",")], :order => :name)
    
    render :partial => "step_three_provinces", :locals => {:province_constraints => @province_constraints}
  end
  
  def update_third_step_districts
    
    unless params[:chart_province_constraints].nil? 
      @district_constraints = District.find(:all, :conditions => ["province_id IN (?)", params[:chart_province_constraints].split(",")], :order => :name)
    else
      @district_constraints = District.find(:all, :conditions => ["country_id IN (?)", params[:chart_country_constraints].split(",")], :order => :name)
    end
    
    render :partial => "step_three_districts", :locals => {:district_constraints => @district_constraints}
  end
  
      
end

class SearchController < ApplicationController
  
  before_filter :authorize
  
  layout 'main_layout'
  
  
  def index
    
    available_countries = Ngo.find(:all, :select => "distinct country_id").map{|ngo| ngo.country_id }
    available_sectors = Ngo.find_by_sql("SELECT DISTINCT sector_id FROM ngos_sectors").map{|ngo| ngo.sector_id }
    available_affiliations = Ngo.find_by_sql("SELECT DISTINCT affiliation_id FROM affiliations_ngos").map{|ngo| ngo.affiliation_id }

    @districts = []
    @provinces = []
    @countries = Country.find(:all, :conditions => ["id in (?)", available_countries], :order => "name")
    @sectors = Sector.find(:all, :conditions => ["id in (?)", available_sectors], :order => "name")
    @affiliations = Affiliation.find(:all, :conditions => ["id in (?)", available_affiliations], :order => "name")
  end
  
  def search
    
    @display_option = params[:display_option]
    @keywords = params[:keywords]
    conditions_hash = {}
    
    # covering the bases here
    if params.member?("advanced")
      conditions_hash[:country_id] = params["advanced"]["countries"] unless params["advanced"]["countries"].nil?
      conditions_hash[:province_id] = params["advanced"]["provinces"] unless params["advanced"]["provinces"].nil?
      conditions_hash[:district_id] = params["advanced"]["districts"] unless params["advanced"]["districts"].nil?
      conditions_hash[:country_id] = params["advanced"]["country_id"] unless params["advanced"]["country_id"].nil?
      conditions_hash[:province_id] = params["advanced"]["province_id"] unless params["advanced"]["province_id"].nil?
      conditions_hash[:district_id] = params["advanced"]["district_id"] unless params["advanced"]["district_id"].nil?
    end        


    if @display_option == "table"
      @search = Ngo.search(@keywords,
                          :include => [:country, :province, :district],
                          :with => conditions_hash,
                          :match_mode => :any, 
                          :page => params[:page], :per_page => 30)
    else
      @search = Ngo.search(@keywords,
                          :include => [:country, :province, :district],
                          :with => conditions_hash,
                          :match_mode => :any,
                          :page => params[:page],
                          :per_page => 40000)
    end
    

    if @display_option == "location_map"
      location_map(@search)
      render :layout => 'maps_layout'
    elsif @display_option == "density_map"
      @results = density_map(@search)
      render :layout => 'vis_layout'
    end

    @advanced = conditions_hash
    
    return @search

  end # end function search
  
  
  
  # do the density mapping
  def density_map(search_results)
        
    # {"entries":[{"region_id":"PK","map_div":"density_canvas","locations":[{"map_label":"PK-IS","map_number":39},{"map_label":"PK-BA","map_number":95}],"column_label":"Region","numeric_label":"Number of Entries"},{"region_id":"AF","map_div":"density_canvas2","locations":[{"map_label":"AF-KAB","map_number":39},{"map_label":"AF-HEL","map_number":30},{"map_label":"AF-KAN","map_number":30}],"column_label":"Region","numeric_label":"Number of Entries"}]}
    
    @maps = {:maps => []}
    results = []
    result_hash = {}
    
    # go through the search results
    search_results.each do |result|
            
      unless result.district.province_id.nil?
                      
        # get the iso code of the result's province
        province = Province.find(result.district.province_id)

        unless province.iso_code.nil?
          
          short_iso = province.iso_code.split("-")[0]
          
          if result_hash[short_iso].nil? # has the country been added to the hash yet?
            
            results << DensityResult.new(short_iso, province.country.name)
            
            result_hash[short_iso] = {:country_name => province.country.name,
                                      :locations => {}}
            result_hash[short_iso][:locations][province.iso_code] = 1
          else
      
            if result_hash[short_iso][:locations][province.iso_code].nil? # is the province already in the province hash?
              result_hash[short_iso][:locations][province.iso_code] = 1
            else
              result_hash[short_iso][:locations][province.iso_code] += 1
            end
      
          end # end result_hash[short_iso].nil?
        end # end unless
      end # end unless
    end # end search_results.each do |result|
    
    result_hash.each do |country_iso, detail_hash|
      
      new_map = {:region_id => country_iso,
                 :map_div => "map_div_#{country_iso.downcase}",
                 :column_label => "Region",
                 :number_label => "NGOs",
                 :locations => []
                }
                
      detail_hash[:locations].each do |province_iso, count|
        new_map[:locations] << {:map_label => province_iso, :map_number => count}
      end
      
      @maps[:maps] << new_map
      
    end
    
    # now that we ahve our results_hash, we need to get the json
    my_file = File.open("#{RAILS_ROOT}/public/data/vis.json", File::WRONLY|File::TRUNC|File::CREAT)
    my_file.puts @maps.to_json.to_s
    my_file.close
    
    return results
    
  end # end function density_map

  
  
  # do the location mapping
  def location_map(search_results)
    
    @latlongs = {}
    @latlong = []
    used_districts = []   
    
    search_results.each do |result|
      unless result.district_id.nil? or result.country_id.nil? or result.district.latlong.nil? or result.district.latlong == ""
        
        if used_districts.include?(result.district_id) # just increase the count
          @latlongs["#{result.district_id}"][:count] += 1
          
        else # add it to the latlongs
          
          used_districts << result.district_id
          district = District.find(result.district_id)
          district.province_id.nil? ? province = nil : province = Province.find(district.province_id)
          district.country_id.nil? ? country = nil : country = Country.find(district.country_id)
          
          @latlongs["#{result.district_id}"] = {:country => country.name,
                                                :province => province.name,
                                                :district => district.name,
                                                :count => 1,
                                                :lat => district.latlong.split(",")[0],
                                                :lng => district.latlong.split(",")[1]}
          
        end      
        
      end
    end # end search_results.each loop
    
    my_file = File.open("#{RAILS_ROOT}/public/data/map.json", File::WRONLY|File::TRUNC|File::CREAT)
    my_file.puts "{\"markers\": #{@latlongs.to_json.to_s} }"
    my_file.close

   # render :text => @latlong.to_json
  end # end function location_map
  
  
  
  def specify
    search_results = search
    update_results_list(search_results)
    #render :partial => "results_panel_results", :locals => {:search => search_results}
  end # end function specify
  
  
  def results
  end
  
  
  # update the fields of the search form on change
  def update_form_fields
    
    available_provinces = Ngo.find(:all, :select => "distinct province_id").map{|ngo| ngo.province_id}
    available_districts = Ngo.find(:all, :select => "distinct district_id").map{|ngo| ngo.district_id}

    if params.member?(:advanced) and (!params[:advanced][:countries].nil? or !params[:advanced][:provinces].nil? or !params[:advanced][:districts].nil?)
      params[:advanced][:countries].nil? ? country_ids = [] : country_ids = params[:advanced][:countries].collect{|id| id.to_i}
      params[:advanced][:provinces].nil? ? province_ids = [] : province_ids = params[:advanced][:provinces].collect{|id| id.to_i}
      params[:advanced][:districts].nil? ? district_ids = [] : district_ids = params[:advanced][:districts].collect{|id| id.to_i}
    else
      country_ids = []
      province_ids = []
      district_ids = []
      @provinces = []
      @districts = []
    end
    
    unless country_ids.empty?
      @provinces = Province.find(:all, :conditions => ["country_id IN (?) and id in (?)", country_ids, available_provinces], :order => "name")
    end
    unless province_ids.empty?
      @districts = District.find(:all, :conditions => ["province_id IN (?) and id in (?)", province_ids, available_districts], :order => "name")
    else
      @districts = District.find(:all, :conditions => ["country_id IN (?)  and id in (?)", country_ids, available_districts], :order => "name")
    end

    render :partial => "list_provinces_districts", :locals => {:provinces => @provinces, :districts => @districts, :selected_provinces => province_ids, :selected_districts => district_ids}
    
  end
  
  
  # get proper provinces for countries selected
  def update_provinces
    country_ids = params[:advanced][:countrie].split(",")
    @provinces = Province.find(:all, :conditions => ["country_id IN (?)", country_ids], :order => "name")
    render :partial => "list_provinces", :locals => {:provinces => @provinces}
  end
  
  # get proper districts for countries selected
  def update_districts_country
    country_ids = params[:country_name].split(",")
    #province_ids = params[:province_name].split(",")
    
    @districts = District.find(:all, :conditions => ["country_id IN (?)", country_ids], :order => "name")
    render :partial => "list_districts", :locals => {:districts => @districts}
  end

  # get proper districts for provinces selected
  def update_districts_province
    province_ids = params[:province_name].split(",")
    @districts = District.find(:all, :conditions => ["province_id IN (?)", province_ids], :order => "name")
    render :partial => "list_districts", :locals => {:districts => @districts}
  end
  
  
  private
  
  def update_results_list(search_results)
    render :update do |page|
      page.replace_html 'results-panel-contents' , :partial => 'results_panel_results', :locals => {:search => search_results}
      page.show 'results-panel-contents'
    end
  end
  
end

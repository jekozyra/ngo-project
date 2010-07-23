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
    
    if(params.member?("countries"))
    	@countries = params[:countries]
    	country_array = @countries
      @countries = "(" + country_array.collect { |i| i }.inject { |i,j| i + ", " + j} + ")"
    else
      @countries = nil
    end
    
    if(params.member?("provinces"))
    	@provinces = params[:provinces]
    	province_array = @provinces
      @provinces = "(" + province_array.collect { |i| i.to_s }.inject { |i,j| i + ", " + j} + ")"
    else
      @provinces = nil
    end
    
    if(params.member?("districts"))
    	@districts = params[:districts]
    	district_array = @districts
      @districts = "(" + district_array.collect { |i| i.to_s }.inject { |i,j| i + ", " + j} + ")"
    else
      @districts = nil
    end
    
    if(params.member?("sector"))
    	@sectors = params[:sector][:name]
    	sector_array = @sectors
      @sectors = "(" + sector_array.collect { |i| i }.inject { |i,j| i + ", " + j} + ")"
    else
      @sectors = nil
    end
    
    if(params.member?("affiliation"))
    	@affiliations = params[:affiliation][:name]
    	affiliation_array = @affiliations
      @affiliations = "(" + affiliation_array.collect { |i| i }.inject { |i,j| i + ", " + j} + ")"
    else
      @affiliations = nil
    end
    
    if(params.member?("sort_by"))
      @sort_by = " order by #{params[:sort_by]}, name"
    else
      @sort_by = " order by name"
    end

    @ngo_name = params[:ngo_name]
    sql = "SELECT ngos.* FROM ngos"
    
    if params[:sort_by] == "country"
      sql+= ", countries"
    elsif params[:sort_by] == "district"
      sql+= ", districts"
    end
    if params[:sort_by] == "affiliation" or params.member?("affiliation")
      sql+= ", affiliations_ngos"
    end
    if params[:sort_by] == "sector" or params.member?("sector")
       sql+= ", ngos_sectors"
    end
    
    unless @countries.nil? and @provinces.nil? and @districts.nil? and @sectors.nil? and @affiliations.nil? and @ngo_name == ""
      sql += " WHERE"
    end
    
    unless @countries.nil?
      sql += " ngos.country_id IN #{@countries}"
    end
    
    unless @provinces.nil?
      unless @countries.nil?
        sql += " AND"
      end
      sql += " ngos.province_id IN #{@provinces}"
    end
    
    unless @districts.nil?
      unless @countries.nil? and @provinces.nil?
        sql += " AND"
      end
      sql += " ngos.district_id IN #{@districts}"
    end
    
    unless @affiliations.nil?
      unless @countries.nil? and @provinces.nil? and @districts.nil?
        sql += " AND"
      end
      sql += " (affiliations_ngos.affiliation_id IN #{@affiliations} and affiliations_ngos.ngo_id = ngos.id)"
    end
    
    unless @ngo_name == ""
      unless @countries.nil? and @provinces.nil? and @districts.nil? and @affiliations.nil?
        sql += " AND"
      end
      sql += " (ngos.name LIKE '%#{@ngo_name}%' or acronym LIKE '%#{@ngo_name}%')"
    end
    
    unless @sectors.nil?
      unless @countries.nil? and @provinces.nil? and @districts.nil? and @affiliations.nil? and @ngo_name == ""
        sql += " AND"
      end
      sql += " (ngos_sectors.sector_id IN #{@sectors} and ngos_sectors.ngo_id = ngos.id)"
    end
    
    if params[:sort_by] == "country"
      sql += " AND ngos.country_id = countries.id"
      @sort_by = " order by countries.name"
    elsif params[:sort_by] == "district"
      sql += " AND ngos.district_id = districts.id"
      @sort_by = " order by districts.name"
    end
    sql += @sort_by
    
    
    if @display_option == "table"
      @search = Ngo.paginate_by_sql(sql, :page => params[:page], :per_page => 50)
    elsif @display_option == "location_map"
      @search = Ngo.find_by_sql(sql)
      location_map(@search)
      render :layout => 'maps_layout'
    elsif @display_option == "density_map"
      @search = Ngo.find_by_sql(sql)
      @results = density_map(@search)
      render :layout => 'vis_layout'
    else
      @search = Ngo.paginate_by_sql(sql, :page => params[:page], :per_page => 50)
    end
    
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
            
      unless result.district.province.id.nil?
                      
        # get the iso code of the result's province
        province = Province.find(result.district.province.id)

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
    
    @latlongs = []
    @latlong = []
    @legend_info = { "Afghanistan" => {"group" => "Afghanistan", "count" => 0}, "Pakistan" => {"group" => "Pakistan", "count" => 0}, "Other" => {"group" => "Other", "count" => 0} }
    used_districts_affiliations = {}    
    
    search_results.each do |result|
      unless result.district_id.nil? or result.country_id.nil? or result.district.latlong.nil?
                
        if used_districts_affiliations[result.district_id].nil?
          used_districts_affiliations[result.district_id] = []
        end
        
        if result.affiliations.empty?

          district_name = result.district.name
          group_name = "Other"
          country_name = "Other"
          lng = result.district.latlong.split(",")[1]
        
          @legend_info[group_name]["count"] += 1
                    
          unless used_districts_affiliations[result.district_id].include?(group_name)
            used_districts_affiliations[result.district_id] << group_name
            lat = result.district.latlong.split(",")[0]

            @latlong << {"country" => country_name,
                        "lat" => lat,
                        "lng" => lng,
                        "group" => group_name,
                        "district" => result.district.name,
                        "district_id" => result.district_id,
                        "country_id" => result.country_id}
          end
        else
          result.affiliations.each do |affiliation|
            
            group_name = ""

            if affiliation.name == "Afghanistan" or affiliation.name == "Pakistan"
              group_name = affiliation.name
              country_name = result.country.name
              district_name = result.district.name
              if affiliation.name == "Pakistan"
                lng = (result.district.latlong.split(",")[1].to_f + 0.14).to_s
              else
                lng = (result.district.latlong.split(",")[1].to_f - 0.13).to_s
              end       
            else
              district_name = result.district.name
              group_name = "Other"
              country_name = "Other"
              lng = result.district.latlong.split(",")[1]
            end
          
            @legend_info[group_name]["count"] += 1
                      
            unless used_districts_affiliations[result.district_id].include?(group_name)
              used_districts_affiliations[result.district_id] << group_name
              lat = result.district.latlong.split(",")[0]

              @latlong << {"country" => country_name,
                          "lat" => lat,
                          "lng" => lng,
                          "group" => group_name,
                          "district" => result.district.name,
                          "district_id" => result.district_id,
                          "country_id" => result.country_id}
            end
          end # end result.affiliations.each do |affiliation|
        end # end if result.affiliaions.nil?
      end
    end # end search_results.each loop
    
    @latlong.sort!{|item1, item2| item1["group"] <=> item2["group"]}
    my_file = File.open("#{RAILS_ROOT}/public/data/map.json", File::WRONLY|File::TRUNC|File::CREAT)
    my_file.puts "{\"markers\":" + @latlong.to_json.to_s + ",\"legend_info\":" + @legend_info.to_json.to_s + "}"
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

    params[:countries].nil? ? country_ids = [] : country_ids = params[:countries].collect{|id| id.to_i}
    params[:provinces].nil? ? province_ids = [] : province_ids = params[:provinces].collect{|id| id.to_i}
    params[:districts].nil? ? district_ids = [] : district_ids = params[:districts].collect{|id| id.to_i}
    
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
    country_ids = params[:country_name].split(",")
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

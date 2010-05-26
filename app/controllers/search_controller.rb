class SearchController < ApplicationController
  
  before_filter :authorize
  
  layout 'main_layout'
  
  def index
    @districts = []
    @countries = Country.find(:all, :order => "name")
    @sectors = Sector.find(:all, :order => "name")
    @affiliations = Affiliation.find(:all, :order => "name")
  end
  
  def search
    
    @display_option = params[:display_option]
    
    if(params.member?("country"))
    	@countries = params[:country][:name]
    	country_array = @countries
      @countries = "(" + country_array.collect { |i| i }.inject { |i,j| i + ", " + j} + ")"
    else
      @countries = nil
    end
    
    if(params.member?("district"))
    	@districts = params[:district][:name]
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
    
    unless @countries.nil? and @districts.nil? and @sectors.nil? and @affiliations.nil? and @ngo_name == ""
      sql += " WHERE"
    end
    
    unless @countries.nil?
      sql += " ngos.country_id IN #{@countries}"
    end
    
    unless @districts.nil?
      unless @countries.nil?
        sql += " AND"
      end
      sql += " ngos.district_id IN #{@districts}"
    end
    
    unless @affiliations.nil?
      unless @countries.nil? and @districts.nil?
        sql += " AND"
      end
      sql += " (affiliations_ngos.affiliation_id IN #{@affiliations} and affiliations_ngos.ngo_id = ngos.id)"
    end
    
    unless @ngo_name == ""
      unless @countries.nil? and @districts.nil? and @affiliations.nil?
        sql += " AND"
      end
      sql += " (ngos.name LIKE '%#{@ngo_name}%' or acronym LIKE '%#{@ngo_name}%')"
    end
    
    unless @sectors.nil?
      unless @countries.nil? and @districts.nil? and @affiliations.nil? and @ngo_name == ""
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
    else
      @search = Ngo.find_by_sql(sql)
    end
    
  end # end function search
  
  
  # do the location mapping
  def location_map(search_results)
    
    @latlongs = []
    @latlong = []
    used_districts = []
    used_affiliations = []
    
    search_results.each do |result|
      unless result.district_id.nil? or result.country_id.nil?
        result.affiliations.each do |affiliation|
          unless used_districts.include?(result.district_id) and used_affiliations.include?(affiliation.id)
            group_name = ""
            
            used_districts << result.district_id

            if affiliation.name == "Afghanistan" or affiliation.name == "Pakistan"
              group_name = affiliation.name
              country_name = result.country.name
              district_name = result.district.name
              used_affiliations << affiliation.name.downcase
              if affiliation.name == "Pakistan"
                lng = (result.district.latlong.split(",")[1].to_f - 0.13).to_s
              else
                lng = result.district.latlong.split(",")[1]
              end       
            else
              district_name = result.district.name
              group_name = "Other"
              country_name = "Other"
              used_affiliations << "other"
              lng = (result.district.latlong.split(",")[1].to_f + 0.13).to_s
            end
            
            lat = result.district.latlong.split(",")[0]

            @latlong << {"country" => country_name,
                         "lat" => lat,
                         "lng" => lng,
                         "group" => group_name}

          end # end unless districts.include?(result.district_id) and affiliations.include?(affiliation.id)
        end
      end
    end # end search_results.each loop

    my_file = File.open("#{RAILS_ROOT}/public/data/map.json", File::WRONLY|File::TRUNC|File::CREAT)
    my_file.puts "{ \"markers\":" + @latlong.to_json.to_s + "}"
    my_file.close

   # render :text => @latlong.to_json
  end # end function location_map
  
  
  def results
  end
  
  # get proper properties and values for language
  def update_districts
    country_ids = params[:country_name].split(",")
    @districts = District.find(:all, :conditions => ["country_id IN (?)", country_ids], :order => "name")
    render :partial => "list_districts", :locals => {:districts => @districts}
  end
  
end

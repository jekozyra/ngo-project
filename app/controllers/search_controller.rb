class SearchController < ApplicationController
  
  layout 'main_layout'
  
  def index
    @districts = []
    @countries = Country.find(:all, :order => "name")
    @sectors = Sector.find(:all, :order => "name")
    @affiliations = Affiliation.find(:all, :order => "name")
  end
  
  def search
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
    
    @search = Ngo.paginate_by_sql(sql, :page => params[:page], :per_page => 50)
    
  end
  
  def results
  end
  
  # get proper properties and values for language
  def update_districts
    country_ids = params[:country_name].split(",")
    @districts = District.find(:all, :conditions => ["country_id IN (?)", country_ids], :order => "name")
    render :partial => "list_districts", :locals => {:districts => @districts}
  end
  
end

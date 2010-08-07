class BrowseController < ApplicationController
  
  layout "main_layout"
  
  def index
  end
  
  def sector_index
    @sectors = Sector.find(:all, :order => :name)
  end

  def country_index
    @countries = Country.all
  end
  
  def by_sector
    @sector = Sector.find(params[:id])
    @ngos = Ngo.paginate_by_sql(["SELECT ngos.* FROM ngos, ngos_sectors, sectors WHERE sectors.id =  #{@sector.id} AND ngos_sectors.sector_id = #{@sector.id} and ngos.id = ngos_sectors.ngo_id ORDER BY ngos.name"],
                                :page => params[:page],
                                :per_page => 40)
  end

  def by_country
    @country = Country.find(params[:id], :include => [:provinces])
  end
  
  def by_province
    
    unless params[:province_id].nil?
      @province = Province.find(params[:province_id])
    end
    @country = Country.find(params[:country_id])
    
    if @province.nil?
      @ngos = Ngo.paginate(:all, :conditions => ["country_id = ?", @country.id], :order => :name, :page => params[:page], :per_page => 40)
    else
      @ngos = Ngo.paginate(:all, :conditions => ["province_id = ?", @province.id], :order => :name, :page => params[:page], :per_page => 40)
    end
  end

end

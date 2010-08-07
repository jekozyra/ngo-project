class DistrictsController < ApplicationController
  
  before_filter :authorize
  before_filter :admin_authorize
  
  layout 'main_layout'
  
  # GET /districts
  # GET /districts.xml
  def index
    
    #Person.find(:all, :include => [ :account, :friends ])
    
    @districts = District.find(:all, :order => "countries.name, provinces.name, districts.name", :include => [:province, :country])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @districts }
    end
  end

  # GET /districts/1
  # GET /districts/1.xml
  def show
    @district = District.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @district }
    end
  end

  # GET /districts/new
  # GET /districts/new.xml
  def new
    @district = District.new
    @provinces = []

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @district }
    end
  end

  # GET /districts/1/edit
  def edit
    @district = District.find(params[:id])
    @provinces = Province.find(:all, :conditions => ["country_id = ?", @district.country_id])
  end

  # POST /districts
  # POST /districts.xml
  def create
    @district = District.new(params[:district])

    respond_to do |format|
      if @district.save
        flash[:notice] = 'District was successfully created.'
        format.html { redirect_to(@district) }
        format.xml  { render :xml => @district, :status => :created, :location => @district }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @district.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /districts/1
  # PUT /districts/1.xml
  def update
        
    @district = District.find(params[:id])
    
    respond_to do |format|
      if @district.update_attributes(params[:district])
        ngo_params = {:country_id => @district.country_id, :province_id => @district.province_id}
        @district.ngos.each do |ngo|
          ngo.update_attributes(ngo_params)
        end
        
        flash[:notice] = 'District was successfully updated.'
        format.html { redirect_to(@district) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @district.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /districts/1
  # DELETE /districts/1.xml
  def destroy
    @district = District.find(params[:id])
    @district.destroy

    respond_to do |format|
      format.html { redirect_to(districts_url) }
      format.xml  { head :ok }
    end
  end
  
  # get proper properties and values for language
  def update_list_provinces
    country_id = params[:district_country_id]
    @provinces = Province.find(:all, :conditions => ["country_id = ?", country_id], :order => "name")
    render :partial => "list_provinces", :locals => {:provinces => @provinces, :province_id => nil}
  end
end

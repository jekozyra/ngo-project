class NgosController < ApplicationController
  
  before_filter :authorize
  before_filter :admin_authorize, :except => ["view_details"]
  
  layout 'main_layout'
  
  # GET /ngos
  # GET /ngos.xml
  def index
    @ngos = Ngo.paginate(:per_page => 30, :page => params[:page], :order => "name")
    #@ngos = Ngo.find(:all, :order => "name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ngos }
    end
  end

  # GET /ngos/1
  # GET /ngos/1.xml
  def show
    @ngo = Ngo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ngo }
    end
  end

  # GET /ngos/new
  # GET /ngos/new.xml
  def new
    @ngo = Ngo.new
    @countries = Country.find(:all, :order => "name")
    @districts = District.find(:all, :conditions => ["country_id = ?", @countries.first.id])
    @sectors = Sector.find(:all, :order => "name")
    @affiliations = Affiliation.find(:all, :order => "name")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ngo }
    end
  end

  # GET /ngos/1/edit
  def edit
    @ngo = Ngo.find(params[:id])
    @countries = Country.find(:all, :order => "name")
    @districts = District.find(:all, :conditions => ["country_id = ?", @countries.first.id])
    @sectors = Sector.find(:all, :order => "name")
    @affiliations = Affiliation.find(:all, :order => "name")
  end

  # POST /ngos
  # POST /ngos.xml
  def create
    @ngo = Ngo.new(params[:ngo])

    respond_to do |format|
      if @ngo.save
        flash[:notice] = 'Ngo was successfully created.'
        format.html { redirect_to(@ngo) }
        format.xml  { render :xml => @ngo, :status => :created, :location => @ngo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ngo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ngos/1
  # PUT /ngos/1.xml
  def update
    @ngo = Ngo.find(params[:id])

    respond_to do |format|
      if @ngo.update_attributes(params[:ngo])
        flash[:notice] = 'Ngo was successfully updated.'
        format.html { redirect_to ngos_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ngo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ngos/1
  # DELETE /ngos/1.xml
  def destroy
    @ngo = Ngo.find(params[:id])
    @ngo.destroy

    respond_to do |format|
      format.html { redirect_to(ngos_url) }
      format.xml  { head :ok }
    end
  end
  
  
  # GET /ngos/1
  # GET /ngos/1.xml
  def view_details
    @ngo = Ngo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  
  def update_districts
    @districts = District.find(:all, :conditions => ["country_id = ?", params[:ngo_country_id].to_i], :order => "name")
    render :partial => "districts", :locals => {:districts => @districts}
  end
  
end

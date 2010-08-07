class DataFilesController < ApplicationController
  
  before_filter :authorize
  before_filter :admin_authorize
  
  layout 'main_layout'
  
  # GET /data_files/new
  # GET /data_files/new.xml
  def new
    @data_file = DataFile.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @data_file }
    end
    
  end


  # POST /data_files
  # POST /data_files.xml
  def create
    
    @data_file = DataFile.new
    @data_file.filename = params[:data_file][:filename].original_filename
    @data_file.filename = params[:data_file][:file_type]

    respond_to do |format|

      if @data_file.valid?
        
        directory = "public/data_uploads"
        # create the file path
        path = File.join(directory, @data_file.filename)
        # write the file
        File.open(path, "wb") { |f| f.write(params[:data_file]['filename'].read) }
        
        if @data_file.file_type == "ACBAR File"
          read_acbar_file(@data_file.filename)
        else
          read_scraped_file(@data_file.filename)
        end
      end
        
      format.html { redirect_to ngos_url }
    end
  end

  def download
    filename = "#{RAILS_ROOT}/public" + params[:data_file]
    send_file filename, :type => 'text/plain'
  end
  
  
  
  def read_acbar_file(filename)

    line_number = 0
    error_messages = []
    
    file = File.open("#{RAILS_ROOT}/public/data_uploads/" + filename)
    
    headers = []

    while (line = file.gets)
      
      if line_number == 0
        headers = line.chomp.split(",")
        headers.each do |header|
          if header == "ACBAR Listing"
            @column_acronym = headers.index(header)
          elsif header == "NGO Name"
            @column_name = headers.index(header)
          elsif header == "Contact Name"
            @column_contact_name = headers.index(header)
          elsif header == "Position"
            @column_contact_position = headers.index(header)
          elsif header == "District"
            @column_district = headers.index(header)
          elsif header == "Phone"
            @column_contact_phone = headers.index(header)
          elsif header == "Email"
            @column_contact_email = headers.index(header)
          elsif header == "Country"
            @column_country = headers.index(header)
          elsif header == "Sector"
            @column_sector = headers.index(header)
          end
        end
        
      else
        line_array = line.chomp.split(",")
        
        # add the proper entries to the district/sector/country tables
        if Country.exists?(:name => line_array[@column_country])
          @country = Country.find_by_name(line_array[@column_country]).id
        else
          @country = Country.create(:name => line_array[@column_country]).id
        end
        
        if District.exists?(:name => line_array[@column_district])
          @district = District.find_by_name(line_array[@column_district]).id
        else
          @district = District.create(:name => line_array[@column_district], :country_id => @country).id
        end
        
        if @column_sector.nil?
          @sector = nil
        else
          if Sector.exists?(:name => line_array[@column_sector])
            @sector = Sector.find_by_name(line_array[@column_sector]).id
          else
            @sector = Sector.create(:name => line_array[@column_sector]).id
          end
        end
        
        if @column_acronym.nil?
          @acronym = nil
        else
          @acronym = line_array[@column_acronym]
        end
        if @column_name.nil?
          @name = nil
        else
          @name = line_array[@column_name]
        end
        if @column_contact_name.nil?
          @contact_name = nil
        else
          @contact_name = line_array[@column_contact_name]
        end
        if @column_contact_phone.nil?
          @contact_phone = nil
        else
          @contact_phone = line_array[@column_contact_phone]
        end
        if @column_contact_address.nil?
          @contact_address = nil
        else
          @contact_address = line_array[@column_contact_address]
        end
        if @column_contact_position.nil?
          @contact_position = nil
        else
          @contact_position = line_array[@column_contact_position]
        end
        if @column_contact_email.nil?
          @contact_email = nil
        else
          @contact_email = line_array[@column_contact_email]
        end
        
        
        @ngo = Ngo.create(:acronym => @acronym,
                          :name => @name,
                          :contact_name => @contact_name,
                          :contact_phone => @contact_phone,
                          :contact_email => @contact_email,
                          :contact_address => @contact_address,
                          :contact_position => @contact_position,
                          :country_id => @country,
                          :district_id => @district,
                          :sector_id => @sector)
                                      
      end # end unless line_number == 0
      
      line_number += 1
      
    end # end while (line = file.gets)
    
    file.close

  end

end

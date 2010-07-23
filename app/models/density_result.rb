class DensityResult
  
  def initialize(iso_code, country_name)
    set_iso_code(iso_code)
    set_country_name(country_name)
  end
  
  def set_iso_code(iso_code)
    @iso_code = iso_code
  end
  
  def set_country_name(country_name)
    @country_name = country_name
  end
  
  def iso_code
    @iso_code
  end
  
  def country_name
    @country_name
  end
  

end
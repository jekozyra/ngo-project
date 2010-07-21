class Contact < ActiveRecord::Base
  has_and_belongs_to_many :ngos
  
  def show_name
    self.name.nil? ? "---" : self.name
  end
  
  def show_phone
    self.phone.nil? ? "---" : self.phone
  end
  
  def show_title
    self.title.nil? ? "---" : self.title
  end
  
  def show_email
    self.email.nil? ? "---" : self.email
  end
  
  def show_contact
    contact = ""
    unless self.name.nil?
      contact += self.name
    end
    unless self.title.nil?
      contact += ". #{self.title}"
    end
    unless self.phone.nil?
      contact += ", #{self.phone}"
    end
    unless self.email.nil?
      contact += ", #{self.email}"
    end
    contact
  end
  
  def show_ngos
    if self.ngos.nil? or self.ngos.size == 0
      "---"
    else
      names = ""
      self.ngos.each do |ngo|
        names += ngo.name
        unless ngo == self.ngos.last
          names += ", "
        end
      end
      names
    end
  end
  
end

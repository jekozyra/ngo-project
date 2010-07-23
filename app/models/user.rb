require 'digest/sha1'

class User < ActiveRecord::Base
  
  validates_presence_of :email, :first_name, :last_name, :who, :how
  validates_uniqueness_of :email
  
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  
  validate :password_non_blank
  
  
  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password or !user.approved
        user = nil
      end
    end
    user
  end
  
  # virtual attribute
  def password
    @password
  end
  
  # virtual attribute
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  def show_who
    self.who.nil? ? "---" : self.who
  end
  
  def show_how
    self.how.nil? ? "---" : self.how
  end
  
  #implement in your user model 
	def admin?
		self.user_type == "admin"
	end
  
  private
  
  def password_non_blank
    errors.add(:password, "Missing password") if hashed_password.blank?
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
end

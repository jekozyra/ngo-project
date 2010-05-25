# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  #filter_parameter_logging :password
  
  def current_user
    @current_user ||= ((session[:user_id] && User.find_by_id(session[:user_id])) || 0)
  end
  
  def logged_in?
    !session[:user_id].nil? and User.exists?(session[:user_id])
  end
  
  private
  
  # make sure that people are logged in to use the system
  def authorize
	  if session[:user_id].nil?
		  session[:original_uri] = request.request_uri
		  redirect_to(login_path)
		  flash[:notice] = "Please login or sign up to access The Mashera Project!"
	  end
  end # end action # authorize
  
  # make sure that people who want to edit data are admins
  def admin_authorize
  	unless User.find(session[:user_id]).user_type == "admin"
  		session[:original_uri] = nil
		  flash[:warning] = "You are not authorized to view this page!"
		  redirect_to(root_path)
  	end
  end # end action admin_authorize
  
end

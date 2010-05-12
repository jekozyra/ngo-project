class AuthenticationController < ApplicationController

  def login
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      if user
        session[:user_id] = user.id
        redirect_to(root_url)
      else
        attempted_login = User.find_by_email(params[:email])
        if attempted_login.nil?
          flash.now[:error] = "Account does not exist. Please sign up."
        elsif attempted_login.approved
          flash.now[:error] = "User/password combination is incorrect"
        else
          flash.now[:error] = "Account has not yet been approved"
        end
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "You have logged out."
    redirect_to(root_url)
  end

end

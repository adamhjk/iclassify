# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include AuthorizedAsUser

  # render new.rhtml
  def new
  end

  def create
    if params[:login] != UUIDREGEX
      self.current_user = User.authenticate(params[:login], params[:password])
    else
      logger.info("Attempt to log in to the web interface with a Node UUID (#{params[:login]})!")
      self.current_user = nil
    end
    if logged_in? 
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include AuthorizedAsUser

  before_filter :login_required

  # render new.rhtml
  def new
  end
  
  def index
    @users = User.find(:all)
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    redirect_back_or_default('/')
    flash[:notice] = "Added user #{@user.login}"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
    @user = User.find_by_id(params[:id])
  end
  
  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "User Updated"
      redirect_to users_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    flash[:notice] = "User Deleted"
    @user.destroy
    if @user.id == current_user.id
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
    end
    redirect_to users_path    
  end

end

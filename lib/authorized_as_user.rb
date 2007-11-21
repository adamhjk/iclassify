module AuthorizedAsUser
  protected
    def authorized?
      logged_in? && current_user.class.to_s == "User"  
    end
    
    def can_write
      if current_user.readwrite == false
        if request.xhr?
          render :text => "You are not allowed to write to iClassify"
        else 
          respond_to do |accepts|
            accepts.html do
              flash[:notice] = "You are not allowed to write to iClassify!"
              redirect_to :controller => '/dashboard', :action => 'index'
            end
            accepts.xml do
              headers["Status"]           = "Unauthorized"
              headers["WWW-Authenticate"] = %(Basic realm="Web Password")
              render :text => "you are not allowed to write to iClassify", :status => '401 Unauthorized'
            end
          end
        end
        false
      else
        true
      end
    end
end
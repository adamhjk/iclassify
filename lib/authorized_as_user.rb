module AuthorizedAsUser
  protected
    def authorized?
      logged_in? && current_user.class.to_s == "User"  
    end
end
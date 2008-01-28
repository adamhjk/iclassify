class LDAPUser
  require 'net/ldap'
  
  attr_accessor :login, :readwrite
  
  def initialize(args)
    @login = args[:login]
    @readwrite = args[:readwrite]
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    self.bind_as?(login,password)
  end
  
  def self.bind_as?(login, password)
    return nil if IC_CONFIG["use_ldap"] != true
    
    ldap = LDAPUser.ldap_setup()
    result = ldap.bind_as(
      :base => ldap_config("auth_basedn"),
      :filter => sprintf(ldap_config("auth_query"), login),
      :password => password
    )
    if result
      readwrite = authz_lookup(ldap, login)
      LDAPUser.new(
        :login => login,
        :readwrite => readwrite
      )
    else
      nil
    end
  end
  
  def id
    @login
  end
  
  def forget_me
    true
  end
  
  def self.find_by_id(login)
    return nil if IC_CONFIG["use_ldap"] != true
    
    ldap = LDAPUser.ldap_setup()
    puts sprintf(ldap_config("auth_query"), login)
    result = ldap.search(
     :base => ldap_config("auth_basedn"),
     :filter => sprintf(ldap_config("auth_query"), login) 
    )
    if result
      readwrite = authz_lookup(ldap, login)
      LDAPUser.new(
        :login => login,
        :readwrite => readwrite
      )
    else
      nil
    end
  end
      
    def self.authz_lookup(ldap, login)
      readwrite = ldap_config("authz_default") == "readwrite" ? true : false
      if ldap_config("authz_use_lookup") == true
        ar = ldap.search(
          :base => ldap_config("authz_basedn"),
          :filter => sprintf(ldap_config("authz_query"), login)
        )
        readwrite = ar ? true : false
      end
      readwrite
    end
    
    def self.ldap_setup()
      ldap = Net::LDAP.new(
        :host => ldap_config("host"),
        :port => ldap_config("port"),
        :base => ldap_config("auth_basedn")
      )
      ldap.encryption = :simple_tls if ldap_config("start_tls") == "true"
      if ldap_config("auth_needs_bind") 
        ldap.authenticate(ldap_config("auth_bind_dn"), ldap_config("auth_bind_pw"))
      end
      ldap
    end
    
    def self.ldap_config(field)
      IC_CONFIG["ldap_config"][field]
    end
    
end

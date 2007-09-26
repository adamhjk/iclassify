ActionController::Routing::Routes.draw do |map|

  map.connect "nodes/autocomplete",
    :controller => "nodes",
    :action => "autocomplete",
    :conditions => { :method => :get }

  map.connect "nodes/:uuid.:format",
    :controller => "nodes",
    :action => "show_uuid",
    :requirements => { 
      :uuid => /[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}/ 
    },
    :conditions => { :method => :get }

  map.connect "nodes/:uuid",
    :controller => "nodes",
    :action => "show_uuid",
    :requirements => { 
      :uuid => /[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}/ 
    },
    :conditions => { :method => :get }
    
  map.connect "nodes/:uuid",
    :controller => "nodes",
    :action => "update_uuid",
    :requirements => { 
      :uuid => /[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}/ 
    },
    :conditions => { :method => :put }
    
  map.connect "nodes/:uuid.:format",
    :controller => "nodes",
    :action => "update_uuid",
    :requirements => { 
      :uuid => /[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}/ 
    },
    :conditions => { :method => :put }
  
  map.connect "search",
    :controller => "search",
    :action => "index"
    
  map.connect "search.:format",
    :controller => "search",
    :action => "index"

  map.connect "tags", 
    :controller => "tags", 
    :action => "all_index", 
    :conditions => { :method => :get }
    
  map.connect "tags.:format", 
    :controller => "tags", 
    :action => "all_index",
    :conditions => { :method => :get }
    
  map.connect "tags", 
    :controller => "tags", 
    :action => "all_create", 
    :conditions => { :method => :post }
    
  map.connect "tags/new", 
    :controller => "tags", 
    :action => "all_new", 
    :conditions => { :method => :get }

  map.connect "tags.:format", 
    :controller => "tags", 
    :action => "all_create",
    :conditions => { :method => :post }
    
  map.connect "tags/:id", 
    :controller => "tags", 
    :action => "all_destroy", 
    :conditions => { :method => :delete }

  map.connect "tags/:id.:format", 
    :controller => "tags", 
    :action => "all_destroy",
    :conditions => { :method => :delete }
    
  map.connect "tags/:id;edit", 
    :controller => "tags", 
    :action => "all_edit",
    :conditions => { :method => :get }
    
  map.connect "tags/:id", 
    :controller => "tags", 
    :action => "all_show",
    :conditions => { :method => :get }
  
  map.connect "tags/:id.format",
    :controller => "tags", 
    :action => "all_show",
    :conditions => { :method => :get }
    
  map.connect "tags/:id",
    :controller => "tags",
    :action => "all_update",
    :conditions => { :method => :post }
    
  map.connect "tags/:id/nodes/:node_id",
    :controller => "tags",
    :action => "all_node_destroy",
    :conditions => { :method => :delete }
    
  map.connect "tags/:id/nodes",
    :controller => "tags",
    :action => "all_node_add",
    :conditions => { :method => :post }
  
  map.resources :nodes do |nodes|
    nodes.resources :tags
    nodes.resources :attribs do |attribs|
      attribs.resources :avalues
    end
  end
  
  map.connect ':all',
    :controller => 'options', 
    :action => 'options', 
    :conditions => { :method => :options },
    :requirements => { :all => /.*/ }
    
  map.connect '', 
    :controller => "dashboard",
    :action => "index",
    :conditions => { :method => :get }
    
  map.connect 'dashboard',
    :controller => "dashboard",
    :action => "index",
    :conditions => { :method => :get }
    
  map.connect 'dashboard/bulk_tag',
    :controller => "dashboard",
    :action => "bulk_tag",
    :conditions => { :method => :post }
    
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end

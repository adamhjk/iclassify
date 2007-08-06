ActionController::Routing::Routes.draw do |map|

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
    
  map.resources :nodes do |nodes|
    nodes.resources :tags
    nodes.resources :attribs do |attribs|
      attribs.resources :avalues
    end
  end
  
  map.connect '', 
    :controller => "dashboard",
    :action => "index",
    :conditions => { :method => :get }
    
  map.connect 'dashboard',
    :controller => "dashboard",
    :action => "index",
    :conditions => { :method => :get }
    
  map.connect 'dashboard/bulk_tag_unclassified',
    :controller => "dashboard",
    :action => "bulk_tag_unclassified",
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

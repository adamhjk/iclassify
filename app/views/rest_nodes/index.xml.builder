xml.nodes do
  @nodes.collect { |n| n.rest_serialize }.each do |node|
    render :partial => "node", 
           :locals => { :xml_instance => xml, :node => node, :node_unique_field => node[:id] }
  end
end
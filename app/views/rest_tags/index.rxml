xml.tags do
  @tags.collect { |t| t.rest_serialize }.each do |tag|
    render :partial => "tag", 
           :locals => { :xml_instance => xml, :tag => tag, :tag_unique_field => tag[:id] }
  end
end
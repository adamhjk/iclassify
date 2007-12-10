render :partial => "tag", 
       :locals => { :xml_instance => xml, :tag => @tag.rest_serialize, :tag_unique_field => @tag.id }
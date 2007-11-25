xml.search do
  xml.nodes do
    @nodes.each do |node|
      xml.node(:link => rest_node_path(:id => node[:uuid])) do
        xml.id(node[:id])
        xml.uuid(node[:uuid])
        xml.description(node[:description])
        xml.notes(node[:notes])
        xml.tags do
          node[:tags].each do |tag|
            xml.tag(tag[:name])
          end
        end
        xml.attribs do
          node[:attribs].each do |attrib|
            xml.attrib do
              xml.name(attrib[:name])
              xml.values do
                attrib[:values].each do |v|
                  xml.value(v)
                end
              end
            end
          end
        end
      end
    end if @nodes
  end
end
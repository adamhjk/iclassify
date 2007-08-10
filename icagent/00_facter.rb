#
# A simple icagent recipe.  Takes all the facter facts and submits them to
# iClassify.
#
  
require 'rubygems'
require 'facter'

Facter.each do |name, value|
  exists = @node.attribs.detect { |a| a[:name] == name }
  if exists
    exists[:values] = [ value ]
  else
    add_attrib(name, value)
  end
end

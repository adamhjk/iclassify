#
# Load all the facter facts
#

require 'rubygems'
require 'facter'

Facter.each do |name, value|
  exists = @node.attribs.detect { |a| a[:name] == name }
  if exists
    exists[:values] = [ value ]
  else
    add_attrib(name, [ value ])
  end
end

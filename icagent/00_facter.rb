#
# A simple icagent recipe.  Takes all the facter facts and submits them to
# iClassify.
#
  
require 'rubygems'
require 'facter'

Facter.each do |name, value|
  replace_attrib(name, value)
end

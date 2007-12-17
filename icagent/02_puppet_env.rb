#
# Set up our puppet environment
# 

unless attrib?("puppet_env")
  hostname = attrib?("hostname")
  fqdn = attrib?("fqdn")
  if fqdn =~ /amazonaws.com$/
    add_attrib("puppet_env", "prod")
  else
    hostname =~ /^.+?\d+(.+)$/
    add_attrib("puppet_env", $1)
  end
end

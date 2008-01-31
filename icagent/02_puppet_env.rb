#
# Set up our puppet environment
# 

unless attrib?("puppet_env")
  hostname = attrib?("hostname")
  fqdn = attrib?("fqdn")
  if fqdn =~ /amazonaws.com$/
    add_attrib("puppet_env", "prod")
  else
    if hostname =~ /^.+?\d+(.+)$/
      add_attrib("puppet_env", $1)
    else
      add_attrib("puppet_env", "prod")
    end
  end
end

#
# Set up our puppet environment
# 

unless attrib?("puppet_env")
  hostname = attrib?("hostname")
  fqdn = attrib?("fqdn")
  if fqdn =~ /amazonaws.com$/
    replace_attrib("puppet_env", "prod")
  else
    if hostname =~ /^.+?\d+(.+)$/
      replace_attrib("puppet_env", $1)
    else
      replace_attrib("puppet_env", "prod")
    end
  end
end

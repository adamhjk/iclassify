#
# Set a tag based on the servers "group", which is pretty arbirtrary, but
# a fine example of why this is really cool.
#
hostname = attrib?("hostname")
if hostname
  if hostname[0] =~ /^(.+?)\d+$/
    add_tag("#{$1}_server")
  else
    add_tag("#{hostname[0]}_server")
  end
end

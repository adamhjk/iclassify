#
# Set a tag based on the servers "group", which is pretty arbirtrary, but
# a fine example of why this is really cool.
#
hostname = attrib?("hostname")
if hostname =~ /^(.+?)\d+$/
  add_tag("#{$1}_server")
else
  add_tag("#{hostname}_server")
end


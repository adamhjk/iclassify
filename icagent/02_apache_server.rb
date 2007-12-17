# 
# Apache should listen on 80, 443 by default.
#

add_attrib("apache_listen_ports", [ 80, 443 ]) unless attrib?("apache_listen_ports")


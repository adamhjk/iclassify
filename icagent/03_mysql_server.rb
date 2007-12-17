#
# How big a buffer pool size?
# 

total_memory = attrib?("memorysize")
if total_memory =~ /MB$/
  total_memory.gsub!(/ MB/, '')
  total_memory = total_memory.to_f
else
  total_memory.gsub!(/ GB/, '')
  total_memory = total_memory.to_f * 1024
end
buffer_pool_size = total_memory * 0.75 
buffer_pool_size = buffer_pool_size.to_i
add_attrib("innodb_buffer_pool_size", buffer_pool_size.to_s + "M") unless attrib?("innodb_buffer_pool_size")

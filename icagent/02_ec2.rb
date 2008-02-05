require 'net/http'

ec2 = false
domain = attrib?('domain')
ec2 = true if domain =~ /\.amazonaws.com$/

if ec2
  replace_attrib("ec2", "true") 
else
  replace_attrib("ec2", "false")
end

def get_from_ec2(thing="/")
  base_url = "http://169.254.169.254/latest/meta-data" + thing
  url = URI.parse(base_url)
  req = Net::HTTP::Get.new(url.path)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  res.body
end

if ec2
  get_from_ec2.split("\n").each do |key|
    add_attrib("ec2-#{key}", get_from_ec2("/#{key}"))
  end
end

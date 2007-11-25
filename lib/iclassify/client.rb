require 'rubygems'
require 'net/https'
require 'rexml/document'
require 'uri'
require 'yaml'

module IClassify

  class Client 
     UUID_REGEX = /^[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}$/
  
    def initialize(service_url, username, password)
      service_url = "#{service_url}/rest" unless service_url =~ /rest$/
      @url = URI.parse(service_url)
      @username = username
      @password = password
    end
  
    def make_url(method, params)
      params[:appid] = @appid
      super method, params
    end

    def search(query, attribs=[])
      raise ArgumentError, "Attributes must be given as a list!" unless attribs.kind_of?(Array)
      querystring = "search"
      querystring << "?q=#{URI.escape(query)}"
      querystring << "&a=#{URI.escape(attribs.join(','))}" if attribs.length > 0
      results = get_rest(querystring, "text/yaml")
      node_array = YAML.load(results).collect { |n| IClassify::Node.new(:yaml, n) }
    end
    
    def get_node(node_id)
      IClassify::Node.new(get_rest("nodes/#{node_id}"))
    end
    
    def update_node(node)
      if node.node_id
        put_rest("nodes/#{node.node_id}", node.to_xml)
      else
        post_rest("nodes", node.to_xml)
      end
    end
    
    def delete_node(node)
      delete_rest("nodes/#{node_id.node_id}")
    end
  
    private
    
      def get_rest(path, accept="application/xml")
        url = URI.parse("#{@url}/#{path}")
        run_request(:GET, url, false, accept)    
      end                               
                                        
      def delete_rest(path, accept="application/xml")             
        url = URI.parse("#{@url}/#{path}")
        run_request(:DELETE, url, false, accept)       
      end                               
                                        
      def post_rest(path, xml, accept="application/xml")          
        url = URI.parse("#{@url}/#{path}")
        run_request(:POST, url, xml, accept)    
      end                               
                                        
      def put_rest(path, xml, accept="application/xml")           
        url = URI.parse("#{@url}/#{path}")
        run_request(:PUT, url, xml, accept)
      end
      
      def run_request(method, url, data=false, accept="application/xml")
        http = Net::HTTP.new(url.host, url.port)
        if url.scheme == "https"
          http.use_ssl = true 
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.read_timeout = 60
        headers = { 
          'Accept' => accept,
          'Content-Type' => accept
        }
        req = nil
        case method
        when :GET
          req_path = "#{url.path}"
          req_path << "?#{url.query}" if url.query
          req = Net::HTTP::Get.new(req_path, headers)
        when :POST
          req = Net::HTTP::Post.new(url.path, headers)
          req.body = data if data
        when :PUT
          req = Net::HTTP::Put.new(url.path, headers)
          req.body = data if data
        when :DELETE
          req = Net::HTTP::Delete.new(url.path, headers)
        end
        req.basic_auth(@username, @password)
        res = http.request(req)
        case res
        when Net::HTTPSuccess
          res.body
        else
          res.error!
        end
      end
        
  end
end
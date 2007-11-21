require 'rubygems'
require 'net/https'
require 'rexml/document'
require 'uri'

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

    def search(query)
      results = post_rest("search", "<q>#{query}</q>")
      xml = REXML::Document.new(results)
      node_array = Array.new
      xml.elements.each("//node") do |node|
        # TODO: Figure out why this needs to be a string.  It's
        #       totally, completely bizzare, most likely because
        #       I'm an idiot with XPath.
        node_array << IClassify::Node.new(node.to_s)
      end
      node_array
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
    
      def get_rest(path, args=false)
        url = URI.parse("#{@url}/#{path}.xml")
        run_request(:GET, url, args)
      end
      
      def delete_rest(path)
        url = URI.parse("#{@url}/#{path}.xml")
        run_request(:DELETE, url)
      end 
      
      def post_rest(path, xml)
        url = URI.parse("#{@url}/#{path}.xml")
        run_request(:POST, url, xml)
      end
      
      def put_rest(path, xml)
        url = URI.parse("#{@url}/#{path}.xml")
        run_request(:PUT, url, xml)
      end
      
      def run_request(method, url, data=false)
        http = Net::HTTP.new(url.host, url.port)
        if url.scheme == "https"
          http.use_ssl = true 
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.read_timeout = 60
        headers = { 
          'Accept' => 'application/xml',
          'Content-Type' => 'application/xml'
        }
        req = nil
        case method
        when :GET
          req = Net::HTTP::Get.new(url.path, headers)
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
require 'rubygems'
require 'net/http'
require 'rexml/document'
require 'uri'

module IClassify

  class Client 
     UUID_REGEX = /^[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}$/
  
    def initialize(service_url)
      @url = URI.parse(service_url)
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
        http.read_timeout = 60
        headers = { 
          'Accept' => 'application/xml',
          'Content-Type' => 'application/xml'
        }
        res = http.send_request(method, url.path, data, headers)
        case res
        when Net::HTTPSuccess
          res.body
        else
          res.error!
        end
      end
        
  end
end
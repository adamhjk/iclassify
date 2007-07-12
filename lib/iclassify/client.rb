require 'rubygems'
require 'rc_rest'
require File.dirname(__FILE__) + '/node'
require 'net/http'
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
      IClassify::Node.from_search(post_rest("search", "<q>#{query}</q>"))
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
        url = URI.parse("#{@url}/#{path}")
        run_request(:get, url, args)
      end
      
      def delete_rest(path)
        url = URI.parse("#{@url}/#{path}")
        run_request(:delete, url)
      end 
      
      def post_rest(path, xml)
        url = URI.parse("#{@url}/#{path}")
        run_request(:post, url, xml)
      end
      
      def put_rest(path, xml)
        url = URI.parse("#{@url}/#{path}")
        run_request(:put, url, xml)
      end
      
      def run_request(method, url, data=false)
        http = Net::HTTP.new(url.host, url.port)
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
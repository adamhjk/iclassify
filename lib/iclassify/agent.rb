require 'rubygems'
require 'facter'
require 'uuid'
require File.dirname(__FILE__) + '/client'
require File.dirname(__FILE__) + '/node'

module IClassify
  class Agent
    attr_accessor :node
    attr_accessor :uuid
    attr_reader :server
    
    def initialize(uuidfile="/etc/icagent/icagent.uuid", server_url="http://localhost:3000")
      @server = URI.parse(server_url)
      @client = IClassify::Client.new(@server)
      if File.exists?(uuidfile)
        IO.foreach(uuidfile) do |line|
          @uuid = line.chomp!
        end
      else
        @uuid = UUID.new
        File.open(uuidfile, "w") do |file|
          file.puts @uuid
        end
      end
    end
    
    def merge_facter
      Facter.each do |name, value|
        exists = @node.attribs.detect { |a| a[:name] = name }
        if exists
          exists[:values] = [ value ]
        else
          @node.attribs << { :name => name, :values => [ value ]}
        end
      end
      @node.attribs
    end
    
    def load
      begin 
        @node = @client.get_node(@uuid)
      rescue Net::HTTPFatalError
        @node = IClassify::Node.new()
        @node.description = "New Node"
        @node.tags << "unconfigured"
        @node.uuid = @uuid
      end
    end
    
    def update
      @client.update_node(@node)
    end 
    
    def delete
      @client.delete_node(@node)
    end
    
    def add_tag(tag)
      load unless @node
      @node.tags << tag
    end
    
    def add_attrib(name, values)
      @node.attribs << { :name => name, :values => values }
    end
    
    def run_script(scriptfile)
      eval(IO.read(scriptfile))
    end
  end
end
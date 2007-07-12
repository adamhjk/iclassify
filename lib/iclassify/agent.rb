require 'rubygems'
require 'uuid'
require File.dirname(__FILE__) + '/client'
require File.dirname(__FILE__) + '/node'

module IClassify
  class Agent
    attr_accessor :node
    attr_accessor :uuid
    
    #
    # Create a new Agent.  Takes a path to a file to either read or drop
    # a UUID, and a server URL.
    #
    def initialize(uuidfile="/etc/icagent/icagent.uuid", server_url="http://localhost:3000")
      @client = IClassify::Client.new(server_url)
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
    
    #
    # Loads data about this node from the iClassify service
    #
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
    
    # 
    # Updates this node in the iClassify service.
    #
    def update
      @client.update_node(@node)
    end 
    
    # 
    # Deletes this node from the iClassify service.
    #
    def delete
      @client.delete_node(@node)
    end
    
    #
    # Returns the tag name if this node has that tag.
    #
    def tag?(tag)
      @node.tags.detect { |t| t == tag }
    end
    
    # Returns the values for this attribute, if it exists for this node.
    def attrib?(attrib)
      na = @node.attribs.detect { |a| a[:name] == attrib }
      na.values
    end
    
    # Returns the value if the given attribute has a given attribute.
    def attrib_has_value?(attrib, value)
      na = @node.attribs.detect { |a| a[:name] == attrib }
      if na 
        return na.values.detect { |v| v == value}
      else
        return nil
      end
    end
    
    # Add a tag to this node.
    def add_tag(tag)
      load unless @node
      @node.tags << tag
    end
    
    # Add an attribute to this node. Requires a name and an array of
    # values. 
    def add_attrib(name, values)
      load unless @node
      @node.attribs << { :name => name, :values => values }
    end
    
    # Run an iclassify script.
    def run_script(scriptfile)
      eval(IO.read(scriptfile))
    end
  end
end
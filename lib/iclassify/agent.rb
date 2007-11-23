require 'rubygems'
require 'uuidtools'

module IClassify
  class Agent
    attr_accessor :node
    attr_accessor :uuid
    attr_accessor :password
    
    #
    # Create a new Agent.  Takes a path to a file to either read or drop
    # a UUID, and a server URL.
    #
    def initialize(uuidfile="/etc/icagent/icagent.uuid", server_url="http://localhost:3000")
      @uuid = nil
      @password = nil
      if File.exists?(uuidfile)
        IO.foreach(uuidfile) do |line|
          @uuid, @password = line.chomp.split("!")
        end
        unless @password
          @password = random_password(30)
          write_uuidfile(uuidfile)
        end
      else
        @uuid = UUID.random_create
        @password = random_password(30)
        write_uuidfile(uuidfile)
      end
      @client = IClassify::Client.new(server_url, @uuid, @password)
    end
    
    #
    # Loads data about this node from the iClassify service
    #
    def load
      begin 
        @node = @client.get_node(@uuid)
      rescue Net::HTTPServerException => e
        if e.to_s =~ /^404/
          @node = IClassify::Node.new()
          @node.description = "New Node"
          @node.tags << "unclassified"
          @node.password = @password
          @node.uuid = @uuid
        else
          throw(e)
        end
      end
    end
    
    # 
    # Updates this node in the iClassify service.
    #
    def update
      if @node.description == "New Node"
        hostname = attrib?("hostname")
        hostname ||= "New Node"
        @node.description = hostname
      end
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
      @node.tag?(tag)
    end
    
    # Returns the values for this attribute, if it exists for this node.  If
    # there is only one, it will return it, if it's an array, you get the 
    # array. You have to check!
    def attrib?(attrib)
      @node.attrib?(attrib)
    end
    
    # Returns the current node as a string.
    def to_s
      @node.to_s
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
    
    # Add an attribute to this node. Requires a name and either a string or
    # array of values.
    def add_attrib(name, values)
      load unless @node
      @node.attribs << { :name => name, :values => values.kind_of?(Array) ? values : [ values ] }
    end
    
    # Run an iclassify script.
    def run_script(scriptfile)
      eval(IO.read(scriptfile))
    end
    
    protected
      def random_password(len)
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        newpass = ""
        1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
        newpass
      end 
      
      def write_uuidfile(uuidfile)
        File.open(uuidfile, "w") do |file|
          file.puts "#{@uuid}!#{@password}"
        end
      end
  end
end
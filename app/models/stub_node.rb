class StubNode
  def initialize(hash)
    @table = {
      :tags => Array.new,
      :attribs => Array.new
    }
    hash.each do |f,v|
      key = f.sub(/(_t)$/, '')
      case key
      when /^(uuid|description|note)$/
        @table[key.to_sym] = v[0]
      when 'pk_i'
        @table[:id] = v[0]
      when 'score'
        @table[:score] = v
      when 'tag'
        v.each { |tv| @table[:tags] << { :name => tv } }
      else
        @table[:attribs] << { :name => key, :values => v }
      end
    end
  end
  
  def id
    @table[:id]
  end
  
  def quarantined
    false
  end
  
  def [](index)
    @table[index.to_sym]
  end
  
  def self.from_solr_query(response)
    if response.docs.length > 0
      stub_nodes = Array.new
      response.docs.each do |doc|
        stub_nodes << StubNode.new(doc)
      end 
      stub_nodes
    else
      Array.new
    end
  end
  
  def load_from_ar
    Node.find_by_id(@table[:pk_i], :include => [ :tags, :attribs ])
  end
  
  def method_missing(key)
    if @table.has_key?(key.to_sym)
      return @table[key]
    end
    nil
  end
  
  def to_hash
    @table
  end

end
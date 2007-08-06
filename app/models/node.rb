class Node < ActiveRecord::Base
  UUID_REGEX = /^[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}$/
  
  has_many :attribs, :dependent => :destroy
  has_and_belongs_to_many :tags
  
  validates_presence_of :uuid
  
  validates_format_of :uuid,
                      :with    => UUID_REGEX,
                      :message => "Must be a valid UUID"
                      
  acts_as_ferret :fields => [ :uuid, :notes, :description, :tag, :attrib ]
  # FIXME: Acts as tree needs to be added, along with consolidating tags and
  #        attribs.
  # acts_as_tree   :order => :uuid 
  
  def tag
    tags.collect { |t| t.name }
  end
  
  def attrib
    resultset = Array.new
    attribs.each do |attrib|
      attrib.avalues.each do |av|
        resultset << "#{attrib.name} #{av.value}"
      end
    end
    resultset
  end
  
  def self.bulk_tag(node_ids, tags)
    node_ids.each do |node_id|
      node = find(node_id.to_i)
      node.tags = tags
      node.save
    end
  end
  
  # Tages an array of tag objects, and updates this node with them.
  # Checks to make sure that a tag isn't applied twice.
  def update_tags(tag_list)
    tag_list.each do |tag|
      begin
        tags.find(tag.id)
      rescue
        tags << tag
      end
    end
    self.save
  end
  
  def save_with_tags_and_attribs(tag_array=nil, attrib_array=nil)
    if tag_array
      Tag.create_missing_tags(tag_array).each { |t| tags << t }
    end
    if attrib_array
      Attrib.create_missing_attribs(self, attrib_array).each { |a| attribs << a }
    end
    self.save
  end
  
  def update_with_tags_and_attribs(params, tag_array=nil, attrib_array=nil)
    logger.debug("Attrib array #{attrib_array.to_yaml}")
    self.update_attributes(params)
    if tag_array
      tags.each do |tag|
        tags.delete(tag) unless tag_array.include?(tag.name)
      end
      self.tags = Tag.create_missing_tags(tag_array)
    end
    if attrib_array
      attribs.each do |attrib|
        attribs.delete(attrib) unless attrib_array.include?({'name' => attrib.name })
      end
      self.attribs = Attrib.create_missing_attribs(self, attrib_array, { :delete => true })
    end
    self.save
  end
  
  # Serializes all the nodes in the database                
  def self.rest_serialize_all
    rest_array = Array.new
    nodes_all = find(:all, :order => :id)
    nodes_all.each do |node|
      rest_array << node.rest_serialize
    end
    rest_array
  end
  
  # Serializes this node
  def rest_serialize
    rest_hash = Hash.new
    rest_hash[:id] = id
    rest_hash[:description] = description
    rest_hash[:notes] = notes
    rest_hash[:uuid] = uuid
    rest_hash[:tags] = Array.new
    tags.each do |tag|
      rest_hash[:tags] << { :id => tag.id, :name => tag.name }
    end
    rest_hash[:attribs] = Array.new
    attribs.each do |attrib|
      ahash = {
        :id => attrib.id,
        :name => attrib.name
      }
      ahash[:values] = attrib.avalues.collect{ |av| av.value }
      rest_hash[:attribs] << ahash
    end
    logger.debug("Rest: #{rest_hash.to_yaml}")
    rest_hash
  end
end

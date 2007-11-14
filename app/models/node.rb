#  iClassify - A node classification service. 
#  Copyright (C) 2007 HJK Solutions and Adam Jacob (<adam@hjksolutions.com>)
# 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class Node < ActiveRecord::Base
  UUID_REGEX = /^[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}$/
  
  has_many :attribs, :dependent => :destroy
  has_and_belongs_to_many :tags
  
  validates_presence_of :uuid
  validates_uniqueness_of :uuid
  
  validates_format_of :uuid,
                      :with    => UUID_REGEX,
                      :message => "Must be a valid UUID"
                      
  # acts_as_ferret(:fields => [ :uuid, :notes, :description, :tag ], :remote =>  true )
  
  acts_as_solr(:fields => [ {:uuid => :text}, {:notes => :text}, {:description => :text}, {:tag => :text} ], 
               :auto_commit => true)
  
  # FIXME: Acts as tree needs to be added.
  # acts_as_tree   :order => :uuid 
  
  # turn this instance into a ferret document (which basically is a hash of
  # fieldname => value pairs)
  #def to_doc
  #  logger.debug "creating doc for class: #{self.class.name}, id: #{self.id}"
  #  returning doc = Ferret::Document.new do
  #    # store the id of each item
  #    doc[:id] = self.id
  #
  #    # store the class name if configured to do so
  #    doc[:class_name] = self.class.name if aaf_configuration[:store_class_name]
  #  
  #    # iterate through the fields and add them to the document
  #    aaf_configuration[:ferret_fields].each_pair do |field, config|
  #      doc[field] = self.send("#{field}_to_ferret") unless config[:ignore]
  #    end
  #    
  #    # Add attribute fields
  #    attribs.each do |attrib|
  #      if attrib.name != "id" && attrib.name != "class_name"
  #        doc[attrib.name] = attrib.avalues.collect {|av| av.value}
  #      end
  #    end
  #  end
  #end
  
  def self.find_record_by_solr(q)
    ids = find_id_by_solr(q, :limit => :all)
    if ids
      logger.debug(ids.to_yaml)
      find_by_sql("SELECT id, uuid, description, notes FROM nodes WHERE id IN (#{ids.docs.join(', ')}) ORDER BY description")
    else
      logger.debug("returning nothing")
      Array.new
    end
  end
  
  # saves to the Solr index
  def solr_save
    return true unless configuration[:if] 
    if evaluate_condition(configuration[:if], self) 
      logger.debug "solr_save: #{self.class.name} : #{record_id(self)}"
      this_doc = to_solr_doc
      field_type = configuration[:facets] && configuration[:facets].include?(field) ? :facet : :text
      field_boost= solr_configuration[:default_boost]
      suffix = get_solr_field_type(field_type)
      attribs.each do |attrib|
        if attrib.name != "id"
          attrib.avalues.collect { |av| av.value }.each do |v|
            v = set_value_if_nil(suffix) if v.to_s == ""
            logger.debug("adding field #{attrib.name}_#{suffix}: #{v.to_s}")
            field = Solr::Field.new("#{attrib.name}_#{suffix}" => ERB::Util.html_escape(v.to_s))
            this_doc << field 
          end
        end
      end
      logger.debug(this_doc.to_xml)
      solr_add(this_doc)
      solr_commit if configuration[:auto_commit]
      true
    else
      solr_destroy
    end
  end
  
  def check_solr_string(v)
    if v =~ /(\.|\_|\:|\*|\(|\)|\-|\=)/
      get_solr_field_type(:text)
    else
      get_solr_field_type(:text)
    end
  end
  
  # Replaces the field types based on the types (if any) specified
  # on the acts_as_solr call
  def replace_types(strings, include_colon=true)
    suffix = include_colon ? ":" : ""
    if configuration[:solr_fields] && configuration[:solr_fields].is_a?(Array)
      configuration[:solr_fields].each do |solr_field|
        field_type = get_solr_field_type(:text)
        if solr_field.is_a?(Hash)
          solr_field.each do |name,value|
       	    if value.respond_to?(:each_pair)
              field_type = get_solr_field_type(value[:type]) if value[:type]
            else
              field_type = get_solr_field_type(value)
            end
            field = "#{name.to_s}_#{field_type}#{suffix}"
            strings.each_with_index { |s,i| strings[i] = s.gsub(/#{name.to_s}_s#{suffix}/,field) }
          end
        end
      end
    end
    strings
  end
  
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
  
  def self.find_by_unique(unique)
    node = nil
    node_unique_field = nil
    case unique
    when /^[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}$/
      node = find_by_uuid(unique)
      node_unique_field = node.uuid if node
    when /^\d+$/
      node = find_by_id(unique)
      node_unique_field = node.id if node
    else
      node = find_by_description(unique)
      logger.info node.to_yaml
      node_unique_field = node.description if node
    end
    return node, node_unique_field
  end
  
  def self.bulk_tag(node_hash, tags)
    node_hash.each do |node_id, value|
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
  
 # def parse_query(query=nil, options={}, models=nil)
 #   valid_options = [:offset, :limit, :facets, :models, :results_format, :order, :scores, :operator]
 #   query_options = {}
 #   return if query.nil?
 #   raise "Invalid parameters: #{(options.keys - valid_options).join(',')}" unless (options.keys - valid_options).empty?
 #   begin
 #     Deprecation.validate_query(options)
 #     query_options[:start] = options[:offset]
 #     query_options[:rows] = options[:limit]
 #     query_options[:operator] = options[:operator]
 #     
 #     # first steps on the facet parameter processing
 #     if options[:facets]
 #       query_options[:facets] = {}
 #       query_options[:facets][:limit] = -1  # TODO: make this configurable
 #       query_options[:facets][:sort] = :count if options[:facets][:sort]
 #       query_options[:facets][:mincount] = 0
 #       query_options[:facets][:mincount] = 1 if options[:facets][:zeros] == false
 #       query_options[:facets][:fields] = options[:facets][:fields].collect{|k| "#{k}_facet"} if options[:facets][:fields]
 #       query_options[:filter_queries] = replace_types(options[:facets][:browse].collect{|k| "#{k.sub!(/ *: */,"_facet:")}"}) if options[:facets][:browse]
 #       query_options[:facets][:queries] = replace_types(options[:facets][:query].collect{|k| "#{k.sub!(/ *: */,"_t:")}"}) if options[:facets][:query]
 #     end
 #     
 #     if models.nil?
 #       # TODO: use a filter query for type, allowing Solr to cache it individually
 #       models = "AND #{solr_configuration[:type_field]}:#{self.name}"
 #       field_list = solr_configuration[:primary_key_field]
 #     else
 #       field_list = "id"
 #     end
 #     
 #     query_options[:field_list] = [field_list, 'score']
 #     query = "(#{query.gsub(/ *: */,"_t:")}) #{models}"
 #     order = options[:order].split(/\s*,\s*/).collect{|e| e.gsub(/\s+/,'_t ').gsub(/\bscore_t\b/, 'score')  }.join(',') if options[:order] 
 #     query_options[:query] = replace_types([query])[0] # TODO adjust replace_types to work with String or Array  
 #
 #     if options[:order]
 #       # TODO: set the sort parameter instead of the old ;order. style.
 #       query_options[:query] << ';' << replace_types([order], false)[0]
 #     end
 #            
 #     ActsAsSolr::Post.execute(Solr::Request::Standard.new(query_options))
 #   rescue
 #     raise "There was a problem executing your search: #{$!}"
 #   end            
 # end
  
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

class Attrib < ActiveRecord::Base
  belongs_to :node
  has_many :avalues, :dependent => :destroy
  
  validates_presence_of :name, :message => "Must have a name"
  
  after_create :update_ferret
  after_update :update_ferret
  after_destroy :update_ferret
  
  def self.get_all_names
    find(:all, :select => "name", :group => "name").collect { |a| a.name }
  end
  
  def self.create_missing_attribs(node, attribs, options=Hash.new)
    attrib_array = Array.new
    attribs.each do |attrib_hash|
      attrib = nil
      if node.id       
        attrib = Attrib.find(:first, :conditions => [ "node_id = ? and name = ?", node.id, attrib_hash['name'] ]) 
        unless attrib
          attrib = node.attribs.new(
             :name => attrib_hash['name']
           )
        end
      else
        attrib = node.attribs.new(
          :name => attrib_hash['name']
        )
      end
      attrib_hash['values']['value'].each do |v|
        unless attrib.avalues.find_by_value(v)
          attrib.avalues << attrib.avalues.new(:value => v)
        end
      end
      logger.debug("Attrib dump: #{attrib.to_yaml}")
      if options.has_key?(:delete) && options[:delete]
        logger.debug("Deleting values that should not be")
        attrib.avalues.each do |av|
          logger.debug("Deleting value #{av.value} unless #{attrib_hash['values']['value'].include?(av.value)}")
          av.destroy unless attrib_hash['values']['value'].include?(av.value)
        end
      end
      logger.debug(" #{attrib.to_yaml}")
      attrib_array << attrib
    end
    attrib_array
  end
      
  def update_ferret
    node.ferret_update
  end
end

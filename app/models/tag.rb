class Tag < ActiveRecord::Base
  has_and_belongs_to_many :nodes
  validates_presence_of :name
  
  after_create  :update_ferret
  after_update  :update_ferret
  after_destroy :update_ferret
  
  def update_ferret
    nodes.each do |node|
      node.ferret_update
    end
  end
  
  def self.create_missing_tags(missing_tags)
    tag_new = Array.new
    missing_tags.each do |t|
      existing = find(:first, :conditions => ["name = ?", t])
      if existing
        tag_new << existing
      else
        new_tag = create(:name => t)
        tag_new << new_tag
      end
    end
    tag_new
  end
  
  def rest_serialize
    rest_hash = Hash.new
    rest_hash[:id] = id
    rest_hash[:name] = name
    rest_hash
  end
  
  def tag_list
  end
  
  def tag_list=(space_tags=nil)
  end
  
end

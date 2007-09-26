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

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :nodes
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, 
    :with => /\A(\w|\-)+\Z/, 
    :message => "Name must be alphanumeric plus _ and -."
  
  after_create  :update_ferret
  after_update  :update_ferret
  after_destroy :update_ferret
  
  def update_ferret
    nodes.each do |node|
      node.ferret_update
    end
  end
  
  def self.find_with_node_count(*args)
    tag_list = find(*args)
    nc_ary = self.connection.select_all("SELECT tag_id, count(*) AS count FROM nodes_tags GROUP BY tag_id")
    node_count = Hash.new
    nc_ary.each do |nc|
      node_count[nc["tag_id"].to_i] = nc["count"].to_i
    end
    tag_list.sort { |a,b| a.name <=> b.name }.collect { |t| { :tag => t, :count => node_count.has_key?(t.id) ? node_count[t.id] : 0 } }
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

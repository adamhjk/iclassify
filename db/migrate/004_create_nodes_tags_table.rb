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

class CreateNodesTagsTable < ActiveRecord::Migration
  def self.up
    create_table :nodes_tags, :id => false do |t|
      t.column :node_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
    end
    
    add_index :nodes_tags, [:node_id]
    add_index :nodes_tags, [:tag_id]
    #execute 'ALTER TABLE nodes_tags ADD CONSTRAINT fk_node_id FOREIGN KEY (node_id) REFERENCES nodes(id)'
    #execute 'ALTER TABLE nodes_tags ADD CONSTRAINT fk_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id)'
  end

  def self.down
    #execute "ALTER TABLE nodes_tags DROP FOREIGN KEY fk_node_id"
    #execute "ALTER TABLE nodes_tags DROP FOREIGN KEY fk_tag_id"
    
    drop_table :nodes_tags
  end
end

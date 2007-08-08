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

class CreateAttribs < ActiveRecord::Migration
  def self.up
    create_table :attribs do |t|
      t.column :node_id, :integer, :null => false
      t.column :name, :string, :null => false
    end
    
    #execute 'ALTER TABLE attribs ADD CONSTRAINT fk_attrib_node_id FOREIGN KEY (node_id) REFERENCES nodes(id)'
  end

  def self.down
    drop_table :attribs
  end
end

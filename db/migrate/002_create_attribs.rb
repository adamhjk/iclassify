class CreateAttribs < ActiveRecord::Migration
  def self.up
    create_table :attribs do |t|
      t.column :node_id, :integer, :null => false
      t.column :name, :string, :null => false
    end
    
    execute 'ALTER TABLE attribs ADD CONSTRAINT fk_attrib_node_id FOREIGN KEY (node_id) REFERENCES nodes(id)'
  end

  def self.down
    drop_table :attribs
  end
end

class CreateNodesTagsTable < ActiveRecord::Migration
  def self.up
    create_table :nodes_tags, :id => false do |t|
      t.column :node_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
    end
    
    add_index :nodes_tags, [:node_id]
    add_index :nodes_tags, [:tag_id]
    execute 'ALTER TABLE nodes_tags ADD CONSTRAINT fk_node_id FOREIGN KEY (node_id) REFERENCES nodes(id)'
    execute 'ALTER TABLE nodes_tags ADD CONSTRAINT fk_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id)'
  end

  def self.down
    execute "ALTER TABLE nodes_tags DROP FOREIGN KEY fk_node_id"
    execute "ALTER TABLE nodes_tags DROP FOREIGN KEY fk_tag_id"
    
    drop_table :nodes_tags
  end
end

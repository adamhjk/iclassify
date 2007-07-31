class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.column :uuid, :string, :limit => 38, :null => false
      t.column :description, :string
      t.column :notes, :text
      # FIXME: This needs to be added, so we can do acts_as_tree
     # t.column :parent_id, :integer
    end
  end

  def self.down
    drop_table :nodes
  end
end

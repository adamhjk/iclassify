class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.column :uuid, :string, :limit => 38, :null => false
      t.column :description, :string
      t.column :notes, :text
    end
  end

  def self.down
    drop_table :nodes
  end
end

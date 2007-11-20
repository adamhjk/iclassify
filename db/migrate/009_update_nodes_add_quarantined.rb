class UpdateNodesAddQuarantined < ActiveRecord::Migration
  def self.up
    add_column :nodes, :quarantined, :boolean, :default => false
  end

  def self.down
    remove_column :nodes, :quarantined
  end
end

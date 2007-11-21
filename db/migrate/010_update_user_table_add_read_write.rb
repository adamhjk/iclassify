class UpdateUserTableAddReadWrite < ActiveRecord::Migration
  def self.up
    add_column :users, :readwrite, :boolean, :default => true
  end

  def self.down
    remove_column :users, :readwrite
  end
end

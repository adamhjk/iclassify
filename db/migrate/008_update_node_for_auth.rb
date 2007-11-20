class UpdateNodeForAuth < ActiveRecord::Migration
  def self.up
    add_column :nodes, :crypted_password, :string, :limit => 40
    add_column :nodes, :salt, :string, :limit => 40
  end

  def self.down
    remove_column :nodes, :crypted_password
    remove_column :nodes, :salt
  end
end

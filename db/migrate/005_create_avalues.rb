class CreateAvalues < ActiveRecord::Migration
  def self.up
    create_table :avalues do |t|
      t.column :attrib_id, :int, :null => false
      t.column :value, :text, :null => false
    end
    
    execute 'ALTER TABLE avalues ADD CONSTRAINT fk_avalues_attrib_id FOREIGN KEY (attrib_id) REFERENCES attribs(id)'
  end

  def self.down
    execute "ALTER TABLE avalues DROP FOREIGN KEY fk_avalues_attrib_id"
    
    drop_table :avalues
  end
end

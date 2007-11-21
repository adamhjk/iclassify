class UpgradeNodeObjects < ActiveRecord::Migration
  require 'tmpdir'
  
  def self.up
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    nodes_to_upgrade = Node.find(:all, :conditions => "crypted_password is NULL" )
    nodes_to_upgrade.each do |node|
      newpass = ""
      1.upto(30) { |i| newpass << chars[rand(chars.size-1)] }
      node.password = newpass
      node.save!
      node_uuid_filename = File.join(Dir.tmpdir, "#{node.description}.uuid")
      puts "New UUID File: #{node_uuid_filename}"
      File.open(node_uuid_filename, 'w') do |uuid_file|
        uuid_file.puts("#{node.uuid}!#{newpass}")
      end
    end
  end
end

class CreateAdminUser < ActiveRecord::Migration
  def self.up
    down
    
    admin_user = User.new(
      :login => "admin",
      :password => "iclassify",
      :password_confirmation => "iclassify"
    )
    admin_user.save!
  end

  def self.down
    User.delete_all
  end
end

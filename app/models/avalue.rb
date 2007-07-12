class Avalue < ActiveRecord::Base
  belongs_to :attrib
  
  validates_presence_of :value, :message => "You must have a value!"
  
  after_create :update_ferret
  after_update :update_ferret
  after_destroy :update_ferret
  
  def update_ferret
    attrib.node.ferret_update
  end
end

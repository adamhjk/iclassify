require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/iclassify/node'

class NodeTest < Test::Unit::TestCase
  XML = IO.read(File.dirname(__FILE__) + '/../data/new_node.xml')
  
  def setup
    @node = IClassify::Node.new(XML)
  end
  
  def test_load_data
    assert(@node.uuid == '7FDA6C6A-F1B4-4F5B-BF49-787459EA74CC', "UUID is wrong")
    assert(@node.notes == 'what about london and terror?', "Notes are wrong")
    assert(@node.description == 'what', "Description is wrong")
    assert(@node.tags == [ 'again', 'alexander', 'monkey', 'poo', 'fighter' ], "Tags are wrong")
    assert(@node.attribs == [ 
      { :name => 'monkey', :values => [ "nuts" ] },
      { :name => 'corona', :values => [ "coffee" ] },
      { :name => 'chocholate', :values => [ "man", "bunny" ] }
      ], "Attribs are wrong")
  end
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

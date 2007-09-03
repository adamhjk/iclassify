require File.dirname(__FILE__) + '/../test_helper'

class NodeTest < Test::Unit::TestCase
  fixtures :nodes

  def test_invalid_node
    node = Node.new
    assert(!node.valid?, "Empty nodes are not valid")
    assert(node.errors.invalid?(:uuid), "uuid must exist")
 
  end
  
  def test_valid_uuid
    node = Node.new
    node.uuid = 'EB1F9086-4314-431B-A834-B68396BBF4B1-FALSE'
    assert(!node.valid?, "UUID must be valid")
    assert(node.errors.invalid?(:uuid), "uuid is invalid")
  end
  
  def test_duplicate_uuid
    node = Node.new(:uuid => nodes(:latte).uuid)
    assert(!node.valid?, "Cannot have a node with a dupe uuid")
    assert(node.errors.invalid?(:uuid), "duplicate uuid is invalid")
  end
end

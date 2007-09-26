require File.dirname(__FILE__) + '/../spec_helper'

describe Node do
  fixtures :nodes
  
  before(:each) do
    @node = Node.new
  end

  it "should be invalid without a uuid" do
    @node.should_not be_valid
    @node.errors.on(:uuid).should eql([ "Must be a valid UUID", "can't be blank" ])

  end
  
  it "should be invalid with a bad uuid" do
    @node.uuid = 'F7028382-B40F-4630-9E8C-A88782D6EDCD-46758'
    @node.should_not be_valid
    @node.errors.on(:uuid).should eql("Must be a valid UUID")
  end
  
  it "should be valid with a proper uuid" do
    @node.attributes = { :uuid => 'F7028382-B40F-4630-9E8C-A88782D6EDCD' }
    @node.should be_valid
  end
  
  it "should be invalid with a non-unique uuid" do
    @node.uuid = nodes(:latte).uuid
    @node.should_not be_valid
    @node.errors.on(:uuid).should eql("has already been taken")
  end
  
  it "should turn itself into a ferret document" do
    nodes(:latte).to_doc.should be_a_kind_of(Ferret::Document)
  end
  
  it "should serialize itself as a hash for rest" do
    nodes(:latte).rest_serialize.should be_a_kind_of(Hash)
  end
  
  it "should serialize all the correct fields for rest" do 
    latte = nodes(:latte)
    latte_hash = latte.rest_serialize
    latte_hash.should be_a_kind_of(Hash)
    latte_hash[:attribs].should eql([])
    latte_hash[:description].should eql(latte.description)
    latte_hash[:notes].should eql(latte.notes)
    latte_hash[:uuid].should eql(latte.uuid)
    latte_hash[:id].should eql(latte.id)
    latte_hash[:tags].should eql([])
  end
  
  it "should serialize every object in the database as an array of hashes" do
    node_list = Node.rest_serialize_all
    node_list.should have(Node.find(:all).length).nodes
    node_list.should be_a_kind_of(Array)
    node_list[0].should be_a_kind_of(Hash)
  end
  
  it "should return a collection of tags for this node" do
    nodes(:latte).tag.should be_a_kind_of(Array)
  end
  
end
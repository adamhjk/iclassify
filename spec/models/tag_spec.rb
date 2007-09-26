require File.dirname(__FILE__) + '/../spec_helper'

describe Tag do
  fixtures :nodes
  fixtures :tags
  
  before(:each) do
    @tag = Tag.new
  end
  
  it "should return a list of tags with node counts" do
    tags(:mastodon).nodes = [ nodes(:latte), nodes(:dosequis) ]
    tags(:web_server).nodes = [ nodes(:latte) ]
    results = Tag.find_with_node_count(:all)
    results.should be_a_kind_of(Array)
    results[0][:count].should eql(2)
  end
end
require File.dirname(__FILE__) + '/../spec_helper'
require 'ostruct'

describe TagsController do
  integrate_views
  
  before(:each) do;
    @tags = Array.new
    mn = mock("node")
    mn.stub!(:description).and_return("monkey")
    mn.stub!(:uuid).and_return("1AF37A3B-52DB-4D23-8B31-312B1E328CC4")
    mn.stub!(:id).and_return(1)
    [ 1, 2, 3 ].each do |t|
      mt = mock("tag")
      mt.stub!(:id).and_return(t)
      mt.stub!(:name).and_return("tag_#{t.to_s}")
      mt.stub!(:nodes).and_return([ mn ])
      @tags << mt
    end
    Tag.stub!(:find).and_return(@tags)
  end
  
  it "should return /tags on all_index" do
    route_for(:controller => "tags", :action => "all_index").should == "/tags"
  end
  
  it "should return /tags/id on all_destroy method delete" do
    route_for(:controller => "tags", 
      :action => "all_destroy", 
      :id => 1, 
      :method => "delete").should == "/tags/1?method=delete"
  end

  it "should return /tags/id;edit on all_edit" do
    route_for(:controller => "tags",
      :action => "all_edit", 
      :id => 1).should == "/tags/1;edit"
  end
  
  it "should return a list of tags on GET to /tags" do
    get :all_index
    assigns[:tags].should equal(@tags)
  end
  
  it "should render tags/all_index.rhtml on GET to /tags" do
    get :all_index
    response.should render_template(:all_index)
  end
  
  it "should have a table with all the tags on GET to /tags" do
    get :all_index
    @tags.each do |t|
      response.should have_tag("div[id='tag_header_#{t.id}']", /#{t.name}/)
    end
  end
  
  it "should render tags/all_index.rxml on GET to /tags" do
    get :all_index, :format => 'xml'
    response.should render_template("tags/all_index.rxml")
  end
  
  it "should have a tag element for each tag in /tags.xml" do
    get :all_index, :format => 'xml'
    @tags.each do |t|
      response.should have_tag("tag[id=#{t.id}]")
    end
  end
  
  it "should return /tags/id on all_show" do
    route_for(:controller => "tags",
      :action => "all_show", 
      :id => 1).should == "/tags/1"
  end
  
  it "should return a single tag on all_show" do
    Tag.should_receive(:find).and_return(@tags[0])
    get :all_show, :id => @tags[0].id
    assigns[:tag].should eql(@tags[0])
  end
  
end

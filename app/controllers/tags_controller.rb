#  iClassify - A node classification service. 
#  Copyright (C) 2007 HJK Solutions and Adam Jacob (<adam@hjksolutions.com>)
# 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class TagsController < ApplicationController
  include AuthorizedAsUser
  
  before_filter :find_node
  before_filter :can_write, :except => [ "index", "show", "all_index", "all_show" ]
  
  # GET /nodes/:node_id/tags/new
  def new
    @tag = Tag.new
  end
  
  # GET /tags/new
  def all_new
    @tag = Tag.new
    if request.xhr? 
      render(:partial => "tag_form", 
        :locals => 
          { 
            :submit => "Create New Tag",
            :remote => true,
            :update => "tag_list_box",
            :url => url_for(:controller => "tags", :action => "all_create")
          }
      )
    end
  end
  
  # GET /nodes/:node_id/tags
  def index
    @tags = @node.tags
  end
  
  # GET /tags/
  def all_index
    @tags = Tag.find(:all, :order => :name)
  end
  
  # GET /tags/:id
  def all_show
    @tag = Tag.find(params[:id])
    @tagged_nodes = get_tagged_nodes
  end
  
  # GET /nodes/:node_id/tags/1;edit
  def edit
    @tag = @node.tags.find(params[:id])
  end
  
  # GET /tags/:tag_id;edit
  def all_edit
    @tag = Tag.find(params[:id])
    @tagged_nodes = get_tagged_nodes
  end

  # POST /nodes/:node_id/tags
  # POST /nodes/:node_id/tags.xml
  def create
    result = false
    if params[:tag_list] == ''
      result = @node.tags.delete(@node.tags)
    else
      tag_set = Tag.create_missing_tags(params[:tag_list].split(' '))
      @node.tags = tag_set
      result = @node.save
    end
    if result
      redirect_to node_path(@node)
    else
      render :action => :new
    end
  end
  
  # POST /tags/:tag_id
  # POST /tags/:tag_id.xml
  def all_create
    @tag = Tag.create(params[:tag])
    if @tag.save
      if request.xhr?
        render(:partial => "/tags/tag_listing")
      else 
        redirect_to url_for(:controller => "tags", :action => "all_show", :id => @tag.id)
      end
    else
      if request.xhr?
        flash[:error] = "Failed to create new tag!"
        render(:partial => "/tags/tag_listing")
        #@tagged_nodes = get_tagged_nodes
        #render :action => :all_edit
      else
        render(:action => :all_new)
      end
    end
  end
  
  # PUT /nodes/:node_id/tags/1
  # PUT /nodes/:node_id/tags/1.xml
  def update
    @tag = @node.tags.find(params[:id])
    if @tag.update_attributes(params[:tag])
      @node.solr_save
      redirect_to node_path(@node)
    else
      render :action => :edit
    end
  end
  
  # PUT /tags/:tag_id
  # PUT /tags/:tag_id.xml
  def all_update
    @tag = Tag.find(params[:id])
    @tagged_nodes = get_tagged_nodes()
    if @tag.update_attributes(params[:tag])
      @tag.update_solr
      redirect_to url_for(:controller => "tags", :action => "all_show", :id => @tag.id)
    else
      render :action => :all_edit
    end
  end

  # DELETE /nodes/:node_id/tags/1
  # DELETE /nodes/:node_id/tags/1.xml
  def destroy
    @node.tags.delete(@node.tags.find(params[:id]))
    @node.solr_save
    redirect_to node_path(@node)
  end
  
  # DELETE /tags/:tag_id
  # DELETE /tags/:tag_id.xml
  def all_destroy
    dtag = Tag.find(params[:id]).destroy
    dtag.update_solr
    if request.xhr? 
      render(:partial => "/tags/tag_listing")
    else
      redirect_to url_for(:controller => "tags", :action => "all_index")
    end
  end
  
  # DELETE /tags/:id/nodes/:node_id
  def all_node_destroy
    @tag = Tag.find(params[:id])
    del_nodes = @tag.nodes.delete(Node.find(params[:node_id]))
    del_nodes.each { |n| n.solr_save }
    if request.xhr?
      render(:partial => "/tags/tagged_nodes", 
        :locals => { 
          :tagged_nodes => @tag.nodes.sort { |a,b| a.description <=> b.description }, 
          :tag => @tag,
          :node_count => @tag.nodes.count,
          :visible => true,
          :update_div_id => "tag_list_2",
        }
      )
    else
      redirect_to url_for(:action => "all_index")
    end
  end
  
  # POST /tags/:id/nodes
  def all_node_add
    @tag = Tag.find(params[:id])
    unless @tag.nodes.detect { |n| n.description == params[:new_node] }
      node = Node.find(:all, :conditions => [ "description = ?", params[:new_node] ])
      @tag.nodes << node
      node.each { |n| n.solr_save }
    end
    if request.xhr?
      render(:partial => "/tags/tagged_nodes", 
        :locals => { 
          :tagged_nodes => @tag.nodes.sort { |a,b| a.description <=> b.description }, 
          :tag => @tag,
          :node_count => @tag.nodes.count,
          :visible => true 
        }
      )
    end
  end
  
  private
  
    def find_node
      if params[:node_id]
        @node_id = params[:node_id]
        redirect_to nodes_path unless @node_id
        @node = Node.find(@node_id)
        @node.from_user = true
      end
    end
    
    def get_tagged_nodes
      @tag.nodes.sort { |a,b| a.description <=> b.description }
    end
end

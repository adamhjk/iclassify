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

class NodesController < ApplicationController
  # GET /nodes
  def index
    @nodes = Node.find(:all) 
  end

  # GET /nodes/1
  def show
    @node = Node.find(params[:id])
  end

  # GET /nodes/new
  def new
    @node = Node.new
  end

  # GET /nodes/1;edit
  def edit
    @node = Node.find(params[:id])
    @tags = @node.tag
  end

  # POST /nodes
  def create
    tags, attribs = populate_tags_and_attribs(params)
    @node = Node.new(params[:node])

    respond_to do |format|
      if @node.save_with_tags_and_attribs(tags, attribs)
        flash[:notice] = 'Node was successfully created.'
        redirect_to node_url(@node)
      else
        render :action => "new"
      end
    end
  end

  # PUT /nodes/1
  def update
    @node = Node.find(params[:id])
    if params[:node].has_key?(:tags) && params[:node].has_key?(:attribs)
      tags, attribs = populate_tags_and_attribs(params)
      if @node.update_with_tags_and_attribs(params[:node], tags, attribs)
        flash[:notice] = 'Node was successfully updated.'
        redirect_to node_url(@node)
      else
        render :action => "edit"
      end
    else
      if @node.update_attributes(params[:node])
        flash[:notice] = 'Node was successfully updated.'
        redirect_to node_url(@node)
      else
        render :action => "edit"
      end
    end
  end

  # DELETE /nodes/1
  def destroy
    @node = Node.find(params[:id])
    @node.destroy
    redirect_to nodes_url
  end
  
  def show_uuid
    @node = Node.find_by_uuid(params[:uuid])
    raise "Cannot find node" unless @node
    redirect_to node_url(@node) 
  end
  
  def update_uuid
    @node = Node.find_by_uuid(params[:uuid])
    raise "Cannot find node" unless @node
    params[:id] = @node.id
    update
  end
    
  def autocomplete
    @nodes = Node.find(:all, :conditions => [ "description LIKE ? ", '%' + params[:q] + '%' ])
    returnv = ""
    @nodes.each do |n|
      returnv << "#{n.description}\n"
    end
    render :text => returnv
  end    

end

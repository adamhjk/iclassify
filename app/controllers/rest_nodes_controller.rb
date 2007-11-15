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

class RestNodesController < ApplicationController
  before_filter :login_required
  
  session :disabled => true
  
  # GET /rest/nodes.xml
  def index
    @nodes = Node.find(:all) 
    
    respond_to do |format|
      format.xml { render :layout => false }
    end
  end

  # GET /rest/nodes/1.xml
  def show
    @node, @node_unique_field = Node.find_by_unique(params[:id])

    respond_to do |format|
      format.xml  { render :layout => false, :template => "rest_nodes/show.rxml" }
    end
  end

  # POST /rest/nodes.xml
  def create
    tags, attribs = populate_tags_and_attribs(params)
    @node = Node.new(params[:node])

    respond_to do |format|
      if @node.save_with_tags_and_attribs(tags, attribs)
        format.xml  { head :created, :location => node_url(@node) }
      else
        format.xml  { render :xml => @node.errors.to_xml }
      end
    end
  end

  # PUT /rest/nodes/1.xml
  def update
    @node, @node_unique_field = Node.find_by_unique(params[:id])

    respond_to do |format|
      if params[:node].has_key?(:tags) && params[:node].has_key?(:attribs)
        tags, attribs = populate_tags_and_attribs(params)
        if @node.update_with_tags_and_attribs(params[:node], tags, attribs)
          format.xml  { head :ok }
        else
          format.xml  { render :xml => @node.errors.to_xml }
        end
      else
        if @node.update_attributes(params[:node])
          format.xml  { head :ok }
        else
          format.xml  { render :xml => @node.errors.to_xml }
        end
      end
    end
  end

  # DELETE /rest/nodes/1.xml
  def destroy
    @node, node_unique_field = Node.find_by_unique(params[:id])
    @node.destroy

    respond_to do |format|
      format.xml  { head :ok }
    end
  end

end

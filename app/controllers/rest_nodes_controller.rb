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
  include AuthorizedAsUser
  before_filter :login_required, :only => [ :index, :destroy ]
  
#  session :disabled => true
  
  # GET /rest/nodes.xml
  def index
    @nodes = Node.find(:all, :include => [ :tags, :attribs ]) 
    
    respond_to do |format|
      format.xml { render :layout => false }
    end
  end

  # GET /rest/nodes/1.xml
  def show
    @node, @node_unique_field = Node.find_by_unique(params[:id])
    if check_node_or_user?(@node)
      respond_to do |format|
        format.xml  { render :layout => false, :template => "rest_nodes/show.xml.builder" }
      end
    else
      if @node
        headers["Status"] = "Unauthorized"
        render :text => "You are neither a user or UUID #{params[:id]}", :status => '401 Unauthorized'
      else
        headers["Status"] = "Not Found"
        render :text => "Cannot find Node with #{params[:id]}", :status => '404 Not Found'
      end
    end
  end

  # POST /rest/nodes.xml
  def create
    tags, attribs = populate_tags_and_attribs(params)
    @node = Node.new(params[:node])
    @node.quarantined = true unless authorized?
    respond_to do |format|
      if @node.save_with_tags_and_attribs(tags, attribs)
        format.xml  { head :created, :location => node_path(@node) }
      else
        format.xml  { render :xml => @node.errors.to_xml }
      end
    end
  end

  # PUT /rest/nodes/1.xml
  def update
    @node, @node_unique_field = Node.find_by_unique(params[:id])
    if check_node_or_user?(@node)
      # You can't take yourself out of quarantine with a parameter
      params[:node].delete(:quarantined) if params[:node].has_key?(:quarantined)
      @node.from_user = true if authorized?
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
    else
      headers["Status"] = "Unauthorized"
      render :text => "You are neither a user or UUID #{params[:node][:uuid]}", :status => '401 Unauthorized'   
    end
  end

  # DELETE /rest/nodes/1.xml
  def destroy
    @node, node_unique_field = Node.find_by_unique(params[:id])
    if check_node_or_user?(@node)
      @node.destroy

      respond_to do |format|
        format.xml  { head :ok }
      end
    else
      headers["Status"] = "Unauthorized"
      render :text => "You are neither a user or UUID #{params[:id]}", :status => '401 Unauthorized'
    end
  end

  protected
    def check_node_or_user?(tocheck)
      return true if current_user.is_a?(User) && current_user.readwrite == true
      return true if current_user.is_a?(Node) && current_user.id == tocheck.id
      return false
    end
    
end

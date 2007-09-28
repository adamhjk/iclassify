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

class AttribsController < ApplicationController
  
  before_filter :find_node
  
  # GET /nodes/:node_id/attribs/new
  def new
    @attrib = Attrib.new
  end
  
  # GET /nodes/:node_id/attribs
  def index
    @attribs = @node.attribs
  end

  # GET /nodes/:node_id/attribs/1;edit
  def edit
    @attrib = @node.attribs.find(params[:id])
  end

  # POST /nodes/:node_id/attribs
  # POST /nodes/:node_id/attribs.xml
  def create    
    @attrib = Attrib.new(params[:attrib])
    
    if (@node.attribs << @attrib)
      flash[:attribute_notice] = "Added attribute #{@attrib.name}"
      if request.xhr?
        render :partial => "/nodes/attrib_list", :locals => {
                :node => @node
          }
      else
        redirect_to(node_url(@node))
      end
    else
      render :action => :new
    end
  end

  # PUT /nodes/:node_id/attribs/1
  # PUT /nodes/:node_id/attribs/1.xml
  def update
    @attrib = @node.attribs.find(params[:id])
    if @attrib.update_attributes(params[:attrib])
      redirect_to node_url(@node)
    else
      render :action => :edit
    end
  end

  # DELETE /nodes/:node_id/attribs/1
  # DELETE /nodes/:node_id/attribs/1.xml
  def destroy
    @attrib = @node.attribs.find(params[:id]).destroy
    flash[:attribute_notice] = "Removed attribute #{@attrib.name}"
    if request.xhr?
      render :partial => "/nodes/attrib_list", :locals => { :node => @node }
    else
      redirect_to node_url(@node) unless request.xhr?
    end
  end
  
  private
    def find_node
      @node_id = params[:node_id]
      redirect_to nodes_url unless @node_id
      @node = Node.find(@node_id)
    end
end

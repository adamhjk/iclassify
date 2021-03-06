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

class AvaluesController < ApplicationController

  include AuthorizedAsUser

  before_filter :login_required
  before_filter :can_write, :except => [ "index", "show" ]
  before_filter :find_attrib
 
 # GET /nodes/:node_id/attribs/new
 def new
   @avalue = Avalue.new
 end
 
 # GET /nodes/:node_id/attribs
 def index
   @avalues = @attrib.avalues
 end

 # GET /nodes/:node_id/attribs/1;edit
 def edit
   @avalue = @attrib.avalues.find(params[:id])
 end

 # POST /nodes/:node_id/attribs
 def create    
   @avalue = Avalue.new(params[:avalue])
   
   if (@attrib.avalues << @avalue)
     @avalue.update_solr
     flash["attrib_edit_#{@attrib.id}_notice".to_sym] = "Added a value"
     if request.xhr?
       render :partial => "nodes/attrib", :locals => { :attrib => @attrib }
     else
       redirect_to node_path(@node)
     end
   else
     render :action => :new
   end
 end

 # PUT /nodes/:node_id/attribs/1
 def update
   @avalue = @attrib.avalues.find(params[:id])
   if @avalue.update_attributes(params[:avalue])
     @avalue.update_solr
     flash["attrib_edit_#{@attrib.id}_notice".to_sym] = "Changed a value"
     if request.xhr?
       render :partial => "nodes/attrib", :locals => { :attrib => @attrib }
     else
       redirect_to node_path(@node)
     end
   else
     render :action => :edit
   end
 end

 # DELETE /nodes/:node_id/attribs/1
 def destroy
   @attrib.avalues.find(params[:id]).destroy
   @node.solr_save
   flash["attrib_edit_#{@attrib.id}_notice".to_sym] = "Removed a value."
   if request.xhr?
     render :partial => "nodes/attrib", :locals => { :attrib => @attrib }
   else
     redirect_to node_path(@node)
   end
 end
 
 private
   def find_attrib
     @node_id = params[:node_id]
     redirect_to nodes_path unless @node_id
     @node = Node.find(@node_id)
     @node.from_user = true
     @attrib_id = params[:attrib_id]
     redirect_to node_attribs_path unless @attrib_id
     @attrib = @node.attribs.find(@attrib_id)
   end
end
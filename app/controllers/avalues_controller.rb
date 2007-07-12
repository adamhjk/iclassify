class AvaluesController < ApplicationController

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
 # POST /nodes/:node_id/attribs.xml
 def create    
   @avalue = Avalue.new(params[:avalue])
   
   if (@attrib.avalues << @avalue)
     redirect_to attribs_url(:node_id => @node.id)
   else
     render :action => :new
   end
 end

 # PUT /nodes/:node_id/attribs/1
 # PUT /nodes/:node_id/attribs/1.xml
 def update
   @avalue = @attrib.avalues.find(params[:id])
   if @avalue.update_attributes(params[:avalue])
     redirect_to attribs_url(:node_id => @node.id)
   else
     render :action => :edit
   end
 end

 # DELETE /nodes/:node_id/attribs/1
 # DELETE /nodes/:node_id/attribs/1.xml
 def destroy
   @attrib.avalues.find(params[:id]).destroy
   redirect_to attribs_url(:node_id => @node.id)
 end
 
 private
   def find_attrib
     @node_id = params[:node_id]
     redirect_to nodes_url unless @node_id
     @node = Node.find(@node_id)
     @attrib_id = params[:attrib_id]
     redirect_to attribs_url unless @attrib_id
     @attrib = @node.attribs.find(@attrib_id)
   end
end
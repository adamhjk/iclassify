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
      redirect_to(node_url(@node)) unless request.xhr?
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
    redirect_to node_url(@node) unless request.xhr?
  end
  
  private
    def find_node
      @node_id = params[:node_id]
      redirect_to nodes_url unless @node_id
      @node = Node.find(@node_id)
    end
end

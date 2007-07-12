class NodesController < ApplicationController
  # GET /nodes
  # GET /nodes.xml
  def index
    @nodes = Node.find(:all) 

    respond_to do |format|
      format.html # index.rhtml
      format.xml { render :layout => false, :template => 'nodes/index.rxml' }
    end
  end

  # GET /nodes/1
  # GET /nodes/1.xml
  def show
    @node = Node.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :layout => false, :template => 'nodes/show.rxml' }
    end
  end

  # GET /nodes/new
  def new
    @node = Node.new
  end

  # GET /nodes/1;edit
  def edit
    @node = Node.find(params[:id])
  end

  # POST /nodes
  # POST /nodes.xml
  def create
    tags, attribs = populate_tags_and_attribs(params)
    @node = Node.new(params[:node])

    respond_to do |format|
      if @node.save_with_tags_and_attribs(tags, attribs)
        flash[:notice] = 'Node was successfully created.'
        format.html { redirect_to node_url(@node) }
        format.xml  { head :created, :location => node_url(@node) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @node.errors.to_xml }
      end
    end
  end

  # PUT /nodes/1
  # PUT /nodes/1.xml
  def update
    tags, attribs = populate_tags_and_attribs(params)
    @node = Node.find(params[:id])

    respond_to do |format|
      if @node.update_with_tags_and_attribs(params[:node], tags, attribs)
        flash[:notice] = 'Node was successfully updated.'
        format.html { redirect_to node_url(@node) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @node.errors.to_xml }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.xml
  def destroy
    @node = Node.find(params[:id])
    @node.destroy

    respond_to do |format|
      format.html { redirect_to nodes_url }
      format.xml  { head :ok }
    end
  end
  
  def show_uuid
    @node = Node.find_by_uuid(params[:uuid])
    params[:id] = @node.id
    respond_to do |format|
      format.html { redirect_to node_url(@node) }
      format.xml  { show }
    end
  end
  
  def update_uuid
    @node = Node.find_by_uuid(params[:uuid])
    params[:id] = @node.id
    respond_to do |format|
      format.xml { update }
    end
  end
  
  
  
  private
    
    def populate_tags_and_attribs(params=nil)
      tags = Array.new
      attribs = Array.new
      if params[:node].has_key?(:tags)
        thash = params[:node].delete(:tags) 
        tags = thash[:tag]
      end
      if params[:node].has_key?(:attribs)
        ahash = params[:node].delete(:attribs)
        attribs = ahash[:attrib]
      end
      logger.debug("Attribs: #{attribs.to_yaml}")
      return tags, attribs
    end
  
end

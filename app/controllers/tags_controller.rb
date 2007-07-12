class TagsController < ApplicationController
  
  before_filter :find_node
  
  # GET /nodes/:node_id/tags/new
  def new
    @tag = Tag.new
  end
  
  # GET /nodes/:node_id/tags
  def index
    @tags = @node.tags
  end
  
  # GET /tags/
  def all_index
    @tags = Tag.find(:all, :order => :name)
  end
  
  # GET /nodes/:node_id/tags/1;edit
  def edit
    @tag = @node.tags.find(params[:id])
  end

  # POST /nodes/:node_id/tags
  # POST /nodes/:node_id/tags.xml
  def create
    tag_set = Tag.create_missing_tags(params[:tag][:tag_list].split(' '))
    
    if @node.update_tags(tag_set)
      redirect_to node_url(@node)
    else
      render :action => :new
    end
  end

  # PUT /nodes/:node_id/tags/1
  # PUT /nodes/:node_id/tags/1.xml
  def update
    @tag = @node.tags.find(params[:id])
    if @tag.update_attributes(params[:tag])
      redirect_to node_url(@node)
    else
      render :action => :edit
    end
  end

  # DELETE /nodes/:node_id/tags/1
  # DELETE /nodes/:node_id/tags/1.xml
  def destroy
    @node.tags.delete(@node.tags.find(params[:id]))
    redirect_to node_url(@node)
  end
  
  private
  
    def find_node
      if params[:node_id]
        @node_id = params[:node_id]
        redirect_to nodes_url unless @node_id
        @node = Node.find(@node_id)
      end
    end
end

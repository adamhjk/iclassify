class DashboardController < ApplicationController
  
  # GET /
  # GET /dashboard
  # GET /dashboard.xml
  def index
    @unclassified_nodes = get_unclassified_nodes()
    @tags = Tag.find(:all)
    @tags ||= Array.new
    @node_pages, @nodes = paginate(:nodes, :order => 'description', :per_page => 20)
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml { render :layout => false, :template => 'dashboard/index.rxml' }
    end
  end
  
  def bulk_tag_unclassified
    if params[:tag_nodes] && params[:tag_list]
      tag_nodes = params[:tag_nodes].kind_of?(Array) ? params[:tag_nodes] : [ params[:tag_nodes] ]
      tags = Tag.create_missing_tags(params[:tag_list].split(" "))
      Node.bulk_tag(tag_nodes, tags)
      flash[:bulk_tags_notice] = "Nodes have been updated."
      redirect_to(url_for(:controller => "dashboard", :action => "index")) unless request.xhr?
      @tags = Tag.find(:all)
      @tags ||= Array.new
      @unclassified_nodes = get_unclassified_nodes()
    else
      flash[:bulk_tags_notice] = "You must select some nodes to tag!"
      redirect_to(url_for(:controller => "dashboard", :action => "index")) unless request.xhr?
      @tags = Tag.find(:all)
      @tags ||= Array.new
      @unclassified_nodes = get_unclassified_nodes()
    end
  end
  
  private
  
    def get_unclassified_nodes
      uctag = Tag.find_by_name("unclassified")
      uctag ? uctag.nodes : Array.new
    end
end

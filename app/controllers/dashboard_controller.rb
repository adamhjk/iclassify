class DashboardController < ApplicationController
  
  # GET /
  # GET /dashboard
  # GET /dashboard.xml
  def index
    uctag = Tag.find_by_name("unclassified")
    @unclassified_nodes = uctag ? uctag.nodes : Array.new
    @tags = Tag.find(:all)
    @tags ||= Array.new
    @node_pages, @nodes = paginate(:nodes, :order => 'description', :per_page => 20)
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml { render :layout => false, :template => 'dashboard/index.rxml' }
    end
  end
  
  def bulk_tag
  end
end

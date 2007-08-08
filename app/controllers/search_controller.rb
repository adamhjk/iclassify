class SearchController < ApplicationController
  def index
    @nodes = Node.find_by_contents(params[:q]) if params[:q]
    @nodes ||= Array.new
    @tags = Tag.find(:all)
    @tags ||= Array.new
    respond_to do |format|
      format.html # index.rhtml
      format.xml { render :layout => false, :template => 'search/index.rxml' }
    end
  end
  
  def bulk_tag
    
  end
end

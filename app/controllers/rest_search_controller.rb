class RestSearchController < ApplicationController
  session :disabled => true
  
  before_filter :login_required
  
  def index
    @nodes = Node.find_record_by_solr(params[:q]) if params[:q]
    @nodes ||= Array.new
    @tags = Tag.find(:all)
    @tags ||= Array.new
    respond_to do |format|
      format.xml { render :layout => false, :template => "rest_search/index.rxml" }
    end
  end
  
  def create
    index
  end
end
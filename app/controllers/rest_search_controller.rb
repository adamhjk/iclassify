class RestSearchController < ApplicationController
  def index
    @nodes = Node.find_by_contents(params[:q], { :limit => :all }, { :order => [ 'description' ]}) if params[:q]
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
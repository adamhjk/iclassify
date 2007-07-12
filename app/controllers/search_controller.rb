class SearchController < ApplicationController
  def index
    @nodes = Node.find_by_contents(params[:q]) if params[:q]
    respond_to do |format|
      format.html # index.rhtml
      format.xml { render :layout => false, :template => 'search/index.rxml' }
    end
  end
end

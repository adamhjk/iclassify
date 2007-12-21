class RestSearchController < ApplicationController
  include AuthorizedAsUser
  
  # session :disabled => true
  before_filter :login_required
  
  def index
    if params.has_key?(:search)
      params[:q] = params[:search][:q] if params[:search][:q]
      params[:a] = params[:search][:a] if params[:search][:a]
    end
    args = { 
      :limit => 10000
    }
    args[:field_list] = params.has_key?(:a) ? params[:a].split(',') : '*' 
    @nodes = Node.find_raw_by_solr(params[:q], args) if params[:q]
    @nodes ||= Array.new
    @tags = Tag.find(:all)
    @tags ||= Array.new
    respond_to do |format|
      format.yaml { render :text => @nodes.collect { |n| n.to_hash }.to_yaml }
      format.json { render :text => [ @nodes.collect { |n| n.to_json } ].to_json }
      format.xml  { render :layout => false, :template => "rest_search/index.xml.builder" }
    end
  end
  
  def create
    index
  end
end
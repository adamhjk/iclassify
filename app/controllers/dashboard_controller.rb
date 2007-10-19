#  iClassify - A node classification service. 
#  Copyright (C) 2007 HJK Solutions and Adam Jacob (<adam@hjksolutions.com>)
# 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class DashboardController < ApplicationController
  
  # GET /
  # GET /dashboard
  # GET /dashboard.xml
  def index
    @unclassified_nodes = get_unclassified_nodes()
    @tags = Tag.find(:all)
    @tags ||= Array.new
    @all_nodes = Node.find(:all)
  end
  
  def bulk_tag
    if params[:tag_nodes] && params[:tag_list]
      tag_nodes = params[:tag_nodes]
      tags = Tag.create_missing_tags(params[:tag_list].split(" "))
      Node.bulk_tag(tag_nodes, tags)
      flash[:bulk_tags_notice] = "Nodes have been updated."
      redirect_to(url_for(:controller => "dashboard", :action => "index")) unless request.xhr?
      @tags = Tag.find(:all)
      @tags ||= Array.new
      @nodes = Node.find_record_by_solr(params[:search_query])
      if params[:search_query] == "tag:unclassified"
        @partial_to_render = "search/bulk_tag"
        @heading = "Unclassified Nodes"
      else
        @partial_to_render = "search/bulk_tag"
        @heading = "Search Results"
      end
    else
      flash[:bulk_tags_notice] = "You must select some nodes to tag!"
      redirect_to(url_for(:controller => "dashboard", :action => "index")) unless request.xhr?
      @tags = Tag.find(:all)
      @tags ||= Array.new
      @nodes = Node.find_record_by_solr(params[:search_query])
      if params[:search_query] == "tag:unclassified"
        @partial_to_render = "search/bulk_tag"
        @heading = "Unclassified Nodes"
      else
        @partial_to_render = "search/bulk_tag"
        @heading = "Search Results"
      end
    end
  end
  
  private
  
    def get_unclassified_nodes
      uctag = Tag.find_by_name("unclassified")
      uctag ? uctag.nodes : Array.new
    end
end

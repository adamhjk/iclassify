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

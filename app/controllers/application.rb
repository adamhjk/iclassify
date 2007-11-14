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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_iclassify_session_id'

  include AuthenticatedSystem
  
  def populate_tags_and_attribs(params=nil)
    tags = Array.new
    attribs = Array.new
    if params[:node].has_key?(:tags)
      thash = params[:node].delete(:tags) 
      tags = thash[:tag]
    end
    if params[:node].has_key?(:attribs)
      ahash = params[:node].delete(:attribs)
      attribs = ahash.kind_of?(Hash) ? [ ahash[:attrib] ] : Array.new
      attribs.flatten!
    end
    logger.debug("Attribs: #{attribs.to_yaml}")
    return tags, attribs
  end
end

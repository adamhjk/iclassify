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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tag_count
    Tag.find_with_node_count(:all, :include => [ :nodes ])
  end
  
  def remove_button(alt, url, confirm)
    link_to(
      image_tag("list-remove.png", :alt => alt, :class => "button"), 
      url, 
      :confirm => confirm, 
      :method => :delete
    )
  end
  
  def add_button(alt, url)
    link_to(
      image_tag("list-add.png", :alt => alt, :class => "button"), 
      url
    )
  end
  
  def toggle_link(options)
    id = options.has_key?(:id) ? options[:id] : raise("Must provide an id!")
    link_text = options.has_key?(:link_text) ? options[:link_text] : raise("Must provide a link")
    url = options.has_key?(:url) ? options[:url] : raise("Must provide an url")
    toggle = options.has_key?(:toggle) ? options[:toggle] : raise("Must provide something to toggle")
    link_to(
      link_text,
      url,
      :id => id,
      :class => "toggle",
      :toggle => toggle
    )
  end
  
  def toggle_spinner(id)
    return "new Effect.toggle($('#{id}'), 'appear')"
  end
  
  def spinner_tag(id)
    return "<span id='#{id}' style='display: none;' class='spinner'>#{image_tag("spinner.gif")}</span>"
  end
  
  def remove_button_remote(id, alt, url, update, confirm)
    jquery_link_to_remote(
      :id => id, 
      :link_text => image_tag("list-remove.png", :alt => alt, :class => "button"),
      :url => url, 
      :update => update, 
      :confirm => confirm,
      :method => :delete
    )
  end
  
  def remove_button_rjs(id, alt, url, confirm)
    jquery_link_to_remote(
      :id => id, 
      :link_text => image_tag("list-remove.png", :alt => alt, :class => "button"),
      :url => url, 
      :update => false, 
      :data_type => "script",
      :confirm => confirm,
      :method => :delete
    )
  end
  
  def jquery_link_to_remote(options)
    id = options.has_key?(:id) ? options[:id] : raise("Must provide an id!")
    link_text = options.has_key?(:link_text) ? options[:link_text] : raise("Must provide a link")
    url = options.has_key?(:url) ? options[:url] : raise("Must provide an url")
    update = options.has_key?(:update) ? options[:update] : raise("Must provide something to update")
    confirm = options.has_key?(:confirm) ? options[:confirm] : nil
    method = options.has_key?(:method) ? options[:method] : :get
    data_type = options.has_key?(:data_type) ? options[:data_type] : "html"
    ajax_options = {
      :id => id,
      :class => "link_to_remote",
      :http_method => method.to_s,
      :data_type => data_type 
    }
    ajax_options[:update] = options[:update] if update
    ajax_options[:confirm_with] = confirm if confirm
    results = link_to(
      link_text,
      url,
      ajax_options
    )
    results << spinner_tag("#{id}_spinner")
  end
  
  def add_button_remote(id, alt, url, update)
    jquery_link_to_remote(
      :id => id, 
      :link_text => image_tag("list-add.png", :alt => alt, :class => "button"), 
      :url => url, 
      :update => update
    )
  end
  
  def edit_button(alt, url)
    link_to(
      image_tag("edit.png", :alt => alt, :class => "button"), 
      url 
    )
  end
  
  def editable_content(options)
     options[:content] = { :element => 'span' }.merge(options[:content])
     options[:url] = {}.merge(options[:url])
     options[:ajax] = { :okText => "'Save'", :cancelText => "'Cancel'"}.merge(options[:ajax] || {})
     script = Array.new
     script << "new Ajax.InPlaceEditor("
     script << "  '#{options[:content][:options][:id]}',"
     script << "  '#{url_for(options[:url])}',"
     script << "  {"
     script << options[:ajax].map{ |key, value| "#{key.to_s}: #{value}" }.join(", ")
     script << "  }"
     script << ")"

     content_tag(
       options[:content][:element],
       options[:content][:text],
       options[:content][:options]
     ) + javascript_tag( script.join("\n") )
   end
end

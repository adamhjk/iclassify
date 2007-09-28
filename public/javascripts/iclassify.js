/* All of our "on page ready" events. */
$(function() {
  /* link_to_remote in jquery */
  $('a.link_to_remote').livequery( "click", function () {
    var spinner_id = "#" + this.id + '_spinner';
    var my_id = "#" + this.id
    var to_update = "#" + $(my_id).attr('update');
    var confirm_with = $(my_id).attr('confirm_with');
    if (confirm_with) {
      if (confirm(confirm_with) == false) {
        return false;
      };
    }
    var ajax_data = {
      url: this.href,
      dataType: "html",
      beforeSend: function(xhr) {
          xhr.setRequestHeader('Accept', 'text/html');          
      },
      success: function(data) {
        $(to_update).html(data).show("fast");
        $(spinner_id).hide();
      }
    }
    var method = $(my_id).attr('http_method');
    if (method == "get") {
      ajax_data["type"] = "GET";
    } else if (method == "post") {
      ajax_data["type"] = "POST";
    } else if (method == "put") {
      ajax_data["type"] = "POST";
      ajax_data["data"] = { _method: 'put' };
    } else if (method == "delete") {
      ajax_data["type"] = "POST";
      ajax_data["data"] = { _method: 'delete' };
    }
    $(spinner_id).show();
    $.ajax(ajax_data);
    return false;
  });
  
  /* toggle an element */
  $('a.toggle').livequery("click", function() { 
    var my_id = "#" + this.id;
    var toggle_id = "#" + $(my_id).attr('toggle');
    $(toggle_id).slideToggle("fast"); 
    return false; 
  });
  
  /* submit a form via XHR */
  $("form.remote_form").livequery(
    function() {
      var to_update = "#" + $(this).attr('update');
      var spinner_id = "#" + $(this).attr('id') + "_spinner";
      $(this).ajaxForm({
        dataType: 'html',
        beforeSubmit: function() { $(spinner_id).show(); },
        beforeSend: function(xhr) {xhr.setRequestHeader("Accept", "text/html");},
        success: function(data) {
          $(to_update).html(data);
          $(spinner_id).hide();
        }
      });
    }
  );
  
  
  $("form.remote_form_rjs").livequery(
    function() {
      var spinner_id = "#" + $(this).attr('id') + "_spinner";
      $(this).ajaxForm({
        dataType: 'script',
        beforeSubmit: function() { $(spinner_id).show(); },
        beforeSend: function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");},
        success: function(data) {
          $(spinner_id).hide();
        } 
      });
    }
  );
  
  
  $("input.autocomplete").livequery(
    function() {
      var url = $(this).attr('autocomplete_url');
      $(this).autocomplete(url);
    }
  );
  
  $("table.nodelist").livequery(
    function() {
      var sort_options;
      if ($(this).is(".bulk_tag")) {
        sort_options = {
          headers: { 0: { sorter: false }, 3: { sorter: false } },
          textExtraction: "complex",
          widthFixed: false
        }
      } else {
        sort_options = {
          headers: { 2: { sorter: false } },
          textExtraction: "complex",
          widthFixed: false
        }
      }
      $(this).tablesorter(sort_options)
    }
  );
  
  $("a.select_all").livequery("click",
    function() {
      var to_select = "input." + $(this).attr('to_select');
      $(to_select).attr("checked", "checked");
      return false;
    }
  );
  
  $("a.unselect_all").livequery("click",
    function() {
      var to_select = "input." + $(this).attr('to_select');
      $(to_select).attr("checked", "");
      return false;
    }
  );
  
  $("a.tag_cloud_entry").livequery("click",
    function() {
      var tag_list = $("input#tag_list");
      var current_tags = tag_list.val()
      var tag = $(this).attr('tag');
      if ($(this).is(".tag_present")) {
        tag_regex = new RegExp(tag)
        current_tags = current_tags.replace(tag_regex, "")
        current_tags = current_tags.replace(/\s+$/, "")
        current_tags = current_tags.replace(/^\s+/, "")
        current_tags = current_tags.replace(/\s{2,}/, " ")
        $(this).removeClass("tag_present");
      } else {
        if (current_tags == "") {
            current_tags = tag
        } else if (current_tags.match(/\s$/)) {
            current_tags += tag
        } else {
            current_tags += " " + tag
        }
        $(this).addClass("tag_present");
      }
      tag_list.val(current_tags);
    }
  );
  
  $("input#tag_list").livequery("change",
    function() {
      current_tags = $(this).val();
      $(".tag_cloud_entry").each(
        function() {
          var me = "a#" + this.id;
          var tag_cloud_id = this.id;
          var tag = $(this).attr("tag");
          var is_tagged_regex = new RegExp('\\b'  + tag + '\\b');
          var me_obj = $(me)
          if (is_tagged_regex.test(current_tags)) {
            if (! me_obj.is(".tag_present")) {
              me_obj.addClass("tag_present");
            }
          } else {
            if (me_obj.is(".tag_present")) {
              me_obj.removeClass("tag_present");
            }
          }
        }
      );
 
    }
  );
 /*  
  function add_present_tag(link, tag, tag_cloud_id) {
      link.addClassName("tag_present")
      link.setAttribute("onclick", "update_tag_list('" + tag + "', '" + tag_cloud_id + "', true); return false;")
  }

  function remove_present_tag(link, tag, tag_cloud_id) {
      link.removeClassName("tag_present")
      link.setAttribute("onclick", "update_tag_list('" + tag + "', '" + tag_cloud_id + "', false); return false;")
  }
  
    */
  /* 
  $("#tag_new_node_<%= tag.id %>").autocomplete('<%= url_for(:controller => "nodes", :action => "autocomplete") %>');
  */
});
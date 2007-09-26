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
      dataType: 'html',
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
  
  $("input.autocomplete").livequery(
    function() {
      var url = $(this).attr('autocomplete_url');
      $(this).autocomplete(url);
    }
  );
    
  /* 
  $("#tag_new_node_<%= tag.id %>").autocomplete('<%= url_for(:controller => "nodes", :action => "autocomplete") %>');
  */
});
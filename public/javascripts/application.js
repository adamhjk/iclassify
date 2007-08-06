function update_tag_list(tag, tag_cloud_id, present) {
    var current_tags = $("tag_list").value
    var link = document.getElementById(tag_cloud_id)
    if (present) {
        tag_regex = new RegExp(tag)
        current_tags = current_tags.replace(tag_regex, "")
        current_tags = current_tags.replace(/\s+$/, "")
        current_tags = current_tags.replace(/^\s+/, "")
        current_tags = current_tags.replace(/\s{2,}/, " ")
        remove_present_tag(link, tag, tag_cloud_id)
    } else {
        if (current_tags == "") {
            current_tags = tag
        } else if (current_tags.match(/\s$/)) {
            current_tags += tag
        } else {
            current_tags += " " + tag
        }
        add_present_tag(link, tag, tag_cloud_id)
    }
    $("tag_list").value = current_tags
}

function add_present_tag(link, tag, tag_cloud_id) {
    link.addClassName("tag_present")
    link.setAttribute("onclick", "update_tag_list('" + tag + "', '" + tag_cloud_id + "', true); return false;")
}

function remove_present_tag(link, tag, tag_cloud_id) {
    link.removeClassName("tag_present")
    link.setAttribute("onclick", "update_tag_list('" + tag + "', '" + tag_cloud_id + "', false); return false;")
}

function autocomplete_manual_tags() {
    var current_tags = $("tag_list").value
    var tags = current_tags.split(" ")
    if (tags) {
        for (var x = 0; x < tags.length; x++) {
            tag = tags[x]
            tag_cloud_id = "tag_cloud_id_" + tag
            var link = document.getElementById(tag_cloud_id)
            if (link) {
                if (! link.hasClassName("tag_present")) {
                    add_present_tag(link, tag, tag_cloud_id)
                }
            }
        }
    }
    present_tags = $("tag_widget").getElementsByClassName("tag_present")
    if (present_tags) {
        for (var x = 0; x < present_tags.length; x++) {
            link = present_tags[x]
            tag_cloud_id = link.readAttribute("id")
            matches = tag_cloud_id.match(/^tag_cloud_id_(.+)$/)
            tag = matches[1]
            tag_regex = new RegExp(tag)
            if (! tag_regex.test(current_tags)) {
                remove_present_tag(link, tag, tag_cloud_id)
            }
        }
    }
}

function select_all_tag_nodes(value) {
    tag_elems = $("bulk_tag").getElementsBySelector("input.tag_node")
    for (var x = 0; x < tag_elems.length; x++) {
       tag_elems[x].checked = value
    }
}

//-- copyright
// OpenProject is a project management system.
//
// Copyright (C) 2012-2013 the OpenProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

jQuery(document).ready(function($) {
  var load_cb, memberstab, update_cb;
  init_members_cb = function () {
    formatItems = function (item, container, query) {
      var match = item.name.toUpperCase().indexOf(query.term.toUpperCase()),
      tl = query.term.length,
      markup = [];

      if (match < 0) {
        return "<span data-value='" + item.id + "'>" +
               OpenProject.Helpers.markupEscape(item.name) + "</span>";
      }

      markup.push(OpenProject.Helpers.markupEscape(
                  item.name.substring(0, match)));
      markup.push("<span class='select2-match' data-value='" + item.id + "'>");
      markup.push(OpenProject.Helpers.markupEscape(
                  item.name.substring(match, match + tl)));
      markup.push("</span>");
      markup.push(OpenProject.Helpers.markupEscape(
                  item.name.substring(match + tl, item.name.length)));
      return markup.join("");
    }

    formatItemSelection = function (item) {
      return OpenProject.Helpers.markupEscape(item.name);
    }
    
    $("#members_add_form select.select2-select").each(function (ix, elem){
      if ($(elem).hasClass("remote") || $(elem).attr("data-ajaxURL") !== undefined) {
        // remote loading
        if (!$.isEmptyObject(elem.siblings('div.select2-select.select2-container'))) {
          setTimeout (function () {
            var attributes, allowed, currentName, fakeInput;
            attributes = {}
            allowed = ["title", "placeholder"];

            for(var i = 0; i < $(elem).get(0).attributes.length; i++) {
              currentName = $(elem).get(0).attributes[i].name;
              if(currentName.indexOf("data-") == 0 || $.inArray(currentName, allowed)); //only ones starting with data-
              attributes[currentName] = $(elem).attr(currentName);
            }
            fakeInput = $(elem).after("<input type='hidden'></input>").siblings(":input:first");
            fakeInput.attr(attributes);

            $(fakeInput).select2({
              multiple: fakeInput.attr("multiple"),
              minimumInputLength: fakeInput.attr("data-minimumInputLength") || 0,
              ajax: {
                  url: $(fakeInput).attr("data-ajaxURL"),
                  quietMillis: 500,
                  dataType: 'json',
                  data: function (term, page) {
                      return {
                          q: term, //search term
                          page_limit: 10, // page size
                          page: page, // current page number
                          id: fakeInput.attr("data-projectId") // current project id
                      };
                  },
                  results: function (data, page) {

                      active_items = []
                      data.results.items.each(function (e) {
                        e.name = $('<pre>').text(e.name).html();
                        active_items.push(e);
                      });
                      return {'results': active_items, 'more': data.results.more};
                  }
              },
              formatResult: formatItems,
              formatSelection: formatItemSelection
            });
            $(elem).remove();
          }, 0);
        }
      } else {
        // no remote loading!
        $(elem).select2();
      }
    });
  }

  memberstab = $('#tab-members').first();
  if ((memberstab != null) && (memberstab.hasClass("selected"))) {
    init_members_cb();
  } else {
    memberstab.click(init_members_cb);
  }
});


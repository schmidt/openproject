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


// Boilerplate code for remote autocompletion/infinite scrolling.
// Borrows graciously from select2

(function ($, undefined) {
  "use strict";

  function TimelinesAutocompleter (object, args) {
    this.element = object;
    this.opts = null;
    this.fakeInput = null;
    this.initOptions(args);
    this.setupInput();
    this.initSelect2();
  }

  TimelinesAutocompleter.prototype = $.extend(TimelinesAutocompleter.prototype, {
    initOptions: function (args) {
      var self = this;
      this.opts = $.extend(true, {}, $.fn.timelinesAutocomplete.defaults);
      this.opts = $.extend(true, this.opts, args[0]);
      if (!(this.element.attr("data-ajaxURL") === "" || this.element.attr("data-ajaxURL") === null || this.element.attr("data-ajaxURL") === undefined)) {
        this.opts.ajax.url = this.element.attr("data-ajaxURL");
      }

    },

    setupInput: function () {
      var attrs_to_copy = {}, currentName, select2id, values = [];

      $("input[name='" + $(this.element).attr("name")+"']").remove();

      for(var i = 0; i < $(this.element).get(0).attributes.length; i++) {
        currentName = $(this.element).get(0).attributes[i].name;
        if(currentName.indexOf("data-") === 0 || $.inArray(currentName, this.opts.allowedAttributes) !== -1) { //only ones starting with data-
          attrs_to_copy[currentName] = $(this.element).attr(currentName);
        }
      }

      select2id = $(this.element).attr("id");
      this.fakeInput = $(this.element).after("<input type='hidden' id='" + select2id + "'></input>").siblings(":input#" + select2id);
      this.fakeInput.attr(attrs_to_copy);
      if (!($(this.element).attr("data-selected") === "" || $(this.element).attr("data-selected") === null || $(this.element).attr("data-selected") === undefined)) {
        JSON.parse($(this.element).attr('data-selected')).each(function (elem) {
          values.push(elem[1]);
        });
        this.fakeInput.val(values);
      }
    },

    initSelect2: function () {
      $(this.element).remove();
      $(this.fakeInput).select2(this.opts);

      if (this.opts.sortable) {
        var input = $(this.fakeInput);
        input.select2("container").find("ul.select2-choices").sortable({
          containment: 'parent',
          start: function() {
            input.select2("onSortStart");
          },
          update: function() {
            input.select2("onSortEnd");
          }
        });
      }
    }
  });

  $.fn.timelinesAutocomplete = function () {
    var args = Array.prototype.slice.call(arguments, 0),
        autocompleter;

    $(this).each(function () {
      autocompleter = new TimelinesAutocompleter($(this), args);
    });
  }

  $.fn.timelinesAutocomplete.defaults = {
    multiple: true,
    allowedAttributes: ["title", "placeholder", "id", "name"],
    minimumInputLength: 0,
    ajax: {
      null_element: null,
      dataType: 'json',
      quietMillis: 500,
      contentType: "application/json",
      data: function (term, page) {
        return {
          q: term, //search term
          page_limit: 10, // page size
          page: page // current page number
        };
      },
      results: function (data, page) {
        var active_items = [];
        data.results.items.each(function (e) {
          active_items.push(e);
        });
        active_items = this.add_null_element(active_items, page);
        return {'results': active_items, 'more': data.results.more};
      },
      add_null_element: function (results, page) {
        if (this.null_element === null || this.null_element === undefined || page !== 1) {
          return results;
        }
        return [this.null_element].concat(results);
      }
    },
    formatResult: function (item, container, query) {
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
    },
    formatSelection: function (item) {
      return OpenProject.Helpers.markupEscape(item.name);
    },
    initSelection: function (element, callback) {
      var data = [];
      if (!($(element).attr("data-selected") === "" || $(element).attr("data-selected") === null || $(element).attr("data-selected") === undefined)) {
        JSON.parse($(element).attr('data-selected')).each(function (elem) {
          data.push({id: elem[1], name: elem[0]});
        });
      }
      return callback(data);
    }
  }
}(jQuery));
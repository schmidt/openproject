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

//requires 'autocompleter'

jQuery(document).ready(function($) {
  [
    $("#reporting_reported_project_status_id"),
    $("#timeline_select"),
    $("#timeline_options_columns"),
    $("#timeline_options_initial_outline_expansion"),
    $("#timeline_options_zoom_factor"),
    $("#timeline_options_compare_to_relative_unit"),
    $("#timeline_options_grouping_one_sort"),
    $("#timeline_options_project_sort"),
    $("#timeline_options_grouping_two_sort"),
    $("#timeline_options_planning_element_time_relative_one_unit"),
    $("#timeline_options_planning_element_time_relative_two_unit")
  ].each(function (item) {
    $("input[name='" + $(item).attr("name")+"']").remove();

    $(item).select2({
      'minimumResultsForSearch': 12
    });
  });

  [
    $("#timeline_options_project_responsibles"),
    $("#timeline_options_project_status"),
    $("#timeline_options_project_types"),
    $("#timeline_options_planning_element_responsibles"),
    $("#timeline_options_planning_element_types"),
    $("#timeline_options_planning_element_time_types"),
    $("#timeline_options_grouping_two_selection")
  ].each(function (item) {
    $(item).timelinesAutocomplete({ ajax: {null_element: {id: -1, name: I18n.t("js.timelines.filter.none")}} })
  });

  [
    $("#reporting_reporting_to_project_id"),
    $("#project_association_select_project_b_id")
  ].each(function (item) {
    // Stuff borrowed from Core application.js Project Jump Box
    $(item).timelinesAutocomplete({
      multiple: false,
      formatSelection: function (item) {
        return item.name || item.project.name;
      },
      formatResult : OpenProject.Helpers.Search.formatter,
      matcher      : OpenProject.Helpers.Search.matcher,
      query        : OpenProject.Helpers.Search.projectQueryWithHierarchy(
                          jQuery.proxy(openProject, 'fetchProjects', item.attr("data-ajaxURL")),
                          20),
      ajax: {}
    });
  });

  [
    $("#timeline_options_grouping_one_selection")
  ].each(function (item) {
    // Stuff borrowed from Core application.js Project Jump Box
    $(item).timelinesAutocomplete({
      sortable: true,
      formatSelection: function (item) {
        return item.name || item.project.name;
      },
      formatResult : OpenProject.Helpers.Search.formatter,
      matcher      : OpenProject.Helpers.Search.matcher,
      query        : OpenProject.Helpers.Search.projectQueryWithHierarchy(
                          jQuery.proxy(openProject, 'fetchProjects'),
                          20),
      ajax: {null_element: {id: -1, name: I18n.t("js.timelines.filter.none")}}
    });
  });

  [
    $("#timeline_options_parents")
  ].each(function (item) {
    // Stuff borrowed from Core application.js Project Jump Box
    $(item).timelinesAutocomplete({
      formatSelection: function (item) {
        return item.name || item.project.name;
      },
      formatResult : OpenProject.Helpers.Search.formatter,
      matcher      : OpenProject.Helpers.Search.matcher,
      query        : OpenProject.Helpers.Search.projectQueryWithHierarchy(
                          jQuery.proxy(openProject, 'fetchProjects'),
                          20),
      ajax: {null_element: {id: -1, name: I18n.t("js.timelines.filter.none")}}
    });
  });

  $("#content").find("input").each(function (index, e) {
    e = $(e);
    if (
        ((e.attr("type") === "text" || e.attr("type") === "hidden") && e.val() !== "" && !e.hasClass("select2-input")) ||
        (e.attr("type") === "checkbox" && e.attr("checked"))
    ) {
      e.closest("fieldset").removeClass('collapsed').children("div").show();
    }
  });
});


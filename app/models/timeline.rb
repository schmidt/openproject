#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class Timeline < ActiveRecord::Base
  class Empty
    attr_accessor :id, :name

    def id
      @id ||= -1
    end

    def name
      @name ||= ::I18n.t('timelines.filter.none')
    end

  end

  unloadable

  serialize :options

  self.table_name = 'timelines'

  default_scope :order => 'name ASC'

  belongs_to :project, :class_name => "Project"

  validates_presence_of :name, :project
  validates_length_of :name, :maximum => 255, :unless => lambda { |e| e.name.blank? }

  attr_accessible :name, :options

  before_save :remove_empty_options_values
  before_save :split_joined_options_values

  @@allowed_option_keys = [
    "columns",
    "compare_to_absolute",
    "compare_to_historical_one",
    "compare_to_historical_two",
    "compare_to_relative",
    "compare_to_relative_unit",
    "comparison",
    "exclude_own_planning_elements",
    "exclude_reporters",
    "exclude_empty",
    "exist",
    "grouping_one_enabled",
    "grouping_one_selection",
    "grouping_one_sort",
    "grouping_two_enabled",
    "grouping_two_selection",
    "grouping_two_sort",
    "hide_chart",
    "hide_other_group",
    "initial_outline_expansion",
    "parents",
    "planning_element_responsibles",
    "planning_element_types",
    "planning_element_time_types",
    "planning_element_time_absolute_one",
    "planning_element_time_absolute_two",
    "planning_element_time_relative_one",
    "planning_element_time_relative_two",
    "planning_element_time_relative_one_unit",
    "planning_element_time_relative_two_unit",
    "planning_element_time",
    "project_responsibles",
    "project_status",
    "project_types",
    "project_sort",
    "timeframe_end",
    "timeframe_start",
    "vertical_planning_elements",
    "zoom_factor"
  ]

  @@available_columns = [
    "project_type",
    "planning_element_types",
    "start_date",
    "end_date",
    "responsible",
    "project_status"
  ]

  @@available_zoom_factors = [
    'years',
    'quarters',
    'months',
    'weeks',
    'days'
  ]

  @@available_initial_outline_expansions = [
    'aggregation',
    'level1',
    'level2',
    'level3',
    'level4',
    'level5',
    'all'
  ]

  def filter_options
    @@allowed_option_keys
  end

  def default_options
    {}
  end

  def options
    read_attribute(:options) || self.default_options
  end

  def options=(other)
    other.assert_valid_keys(*filter_options)
    write_attribute(:options, other)
  end

  def json_options
    json = with_escape_html_entities_in_json{ options.to_json }
    json.html_safe
  end

  def available_columns
    @@available_columns
  end

  def available_initial_outline_expansions
    @@available_initial_outline_expansions
  end

  def selected_initial_outline_expansion
    if options["initial_outline_expansion"].present?
      options["initial_outline_expansion"].first.to_i
    else
      -1
    end
  end

  def available_zoom_factors
    @@available_zoom_factors
  end

  def selected_zoom_factor
    if options["zoom_factor"].present?
      options["zoom_factor"].first.to_i
    else
      -1
    end
  end

  def available_planning_element_types

    # TODO: this should not be all planning element types, but instead
    # all types that are available in the project the timeline is
    # referencing, and all planning element types available in projects
    # that are reporting into the project that this timeline is
    # referencing.

    PlanningElementType.find(:all, :order => :name)
  end

  def selected_planning_element_types
    resolve_with_none_element(:planning_element_types) do |ary|
      PlanningElementType.find(ary)
    end
  end

  def selected_planning_element_time_types
    resolve_with_none_element(:planning_element_time_types) do |ary|
      PlanningElementType.find(ary)
    end
  end

  def available_project_types
    ProjectType.find(:all)
  end

  def selected_project_types
    resolve_with_none_element(:project_types) do |ary|
      ProjectType.find(ary)
    end
  end

  def available_project_status
    ReportedProjectStatus.find(:all, :order => :name)
  end

  def selected_project_status
    resolve_with_none_element(:project_status) do |ary|
      ReportedProjectStatus.find(ary)
    end
  end

  def available_responsibles
    User.find(:all).sort_by(&:name)
  end

  def selected_project_responsibles
    resolve_with_none_element(:project_responsibles) do |ary|
      User.find(ary)
    end
  end

  def selected_planning_element_responsibles
    resolve_with_none_element(:planning_element_responsibles) do |ary|
      User.find(ary)
    end
  end

  def available_parents
    selectable_projects
  end

  def selected_parents
    resolve_with_none_element(:parents) do |ary|
      Project.find(ary)
    end
  end

  def selected_columns
    if options["columns"].present?
      options["columns"]
    else
      []
    end
  end

  def planning_element_time
    if options["planning_element_time"].present?
      options["planning_element_time"]
    else
      'absolute'
    end
  end

  def comparison
    if options["comparison"].present?
      options["comparison"]
    else
      'none'
    end
  end

  def selected_grouping_projects
    resolve_with_none_element(:grouping_one_selection) do |ary|
      projects = Project.find(ary)
      projectsHashMap = Hash[projects.collect { |v| [v.id, v]}]

      ary.map { |a| projectsHashMap[a] }
    end
  end

  def available_grouping_projects
    selectable_projects
  end

  def selectable_projects
    Project.selectable_projects
  end

  def selected_grouping_project_types
    resolve_with_none_element(:grouping_two_selection) do |ary|
      ProjectType.find(ary)
    end
  end

  def available_grouping_project_types
    ProjectType.available_grouping_project_types
  end

  protected

  def remove_empty_options_values
    unless self[:options].nil?
      self[:options].reject! do |key, value|
        value.instance_of?(Array) && value.length == 1 && value.first.empty?
      end
    end
  end

  def split_joined_options_values
    unless self[:options].nil?
      self[:options].each_pair do |key, value|
        if value.instance_of?(Array) && value.length == 1 then
          self[:options][key] = value[0].split(",")
        end
      end
    end
  end

  def array_of_ids_or_empty_array(options_field)
    array_or_empty(options_field) { |ary| ary.delete_if(&:empty?).map(&:to_i) }
  end

  def array_or_empty(options_field)
    if options[options_field].present?
      if block_given?
        yield options[options_field]
      else
        return options[options_field]
      end
    else
      []
    end
  end

  def resolve_with_none_element(options_field, &block)
    collection = []
    collection += [Empty.new] if (ary = array_of_comma_seperated(options_field)).delete(-1)
    begin
      collection += block.call(ary);
    rescue

    end
    return collection
  end

  def array_of_comma_seperated(options_field)
    array_or_empty(options_field) do |ary|
      ary.map(&:to_i).reject do |value|
        value < -1 || value == 0
      end
    end
  end

  # TODO: this should go somewhere else, once it is needed at multiple places
  def with_escape_html_entities_in_json
    oldvalue = ActiveSupport.escape_html_entities_in_json
    ActiveSupport.escape_html_entities_in_json = true

    yield
  ensure
    ActiveSupport.escape_html_entities_in_json = oldvalue
  end
end

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

Given /^the [pP]roject "([^\"]*)" has the parent "([^\"]*)"$/ do |child_name, parent_name|
  parent = Project.find_by_name(parent_name)
  child = Project.find_by_name(child_name)

  child.set_parent!(parent);
  child.save!
end

Given /^there are the following colors:$/ do |table|
  table.map_headers! { |header| header.underscore.gsub(' ', '_') }

  table.hashes.each do |type_attributes|
    FactoryGirl.create(:color, type_attributes)
  end
end

Given /^I am working in the [tT]imeline "([^"]*)" of the project called "([^"]*)"$/ do |timeline_name, project_name|
  @project = Project.find_by_name(project_name)
  @timeline_name = timeline_name
end

Given /^there are the following planning element types:$/ do |table|
  # Color is not handled in a sensible way. We need some extra logic to match
  # a color name to an id, so that it is possible to assign a certain color to
  # planning element types. This should be added once it is needed.
  #
  table.map_headers! { |header| header.underscore.gsub(' ', '_') }

  table.hashes.each do |type_attributes|
    FactoryGirl.create(:planning_element_type, type_attributes)
  end
end

Given /^there are the following planning element statuses:$/ do |table|
  table.map_headers! { |header| header.underscore.gsub(' ', '_') }

  table.hashes.each do |type_attributes|
    FactoryGirl.create(:planning_element_status, type_attributes)
  end
end

Given /^there are the following reported project statuses:$/ do |table|
  table.map_headers! { |header| header.underscore.gsub(' ', '_') }

  table.hashes.each do |type_attributes|
    FactoryGirl.create(:reported_project_status, type_attributes)
  end
end

Given /^there are the following project types:$/ do |table|
  table.map_headers! { |header| header.underscore.gsub(' ', '_') }

  table.hashes.each do |type_attributes|
    FactoryGirl.create(:project_type, type_attributes)
  end
end

Given (/^there are the following planning elements(?: in project "([^"]*)")?:$/) do |project_name, table|
  project = get_project(project_name)
  table.map_headers! { |header| header.underscore.gsub(' ', '_') }

  table.hashes.each do |type_attributes|
    status = PlanningElementStatus.find_by_name(type_attributes.delete("status_name"))
    responsible = User.find_by_login(type_attributes.delete("responsible"))
    planning_element_type = PlanningElementType.find_by_name(type_attributes.delete("planning_element_type"));

    factory = FactoryGirl.create(:planning_element, type_attributes.merge(:project_id => project.id))

    factory.reload

    factory.planning_element_status = status unless status.nil?
    factory.responsible = responsible unless responsible.nil?
    factory.planning_element_type = planning_element_type unless planning_element_type.nil?
    factory.save! if factory.changed?
  end
end


Given /^the following planning element types are default for projects of type "([^"]*)"$/ do |project_type_name, pe_type_names|
  project_type = ProjectType.find_by_name!(project_type_name)

  pe_type_names = pe_type_names.raw.flatten
  pe_type_names.each do |pe_type_name|
    FactoryGirl.create(:default_planning_element_type,
                   :project_type_id          => project_type.id,
                   :planning_element_type_id => PlanningElementType.find_by_name!(pe_type_name).id)
  end
end

Given /^there is a scenario "([^"]*)" in project "([^"]*)"$/ do |scenario_name, project_name|
  FactoryGirl.create(:scenario, :name => scenario_name, :project_id => Project.find_by_name!(project_name).id)
end


#Factory.create(:timelines_reporting, :project => add_project, :reporting_to_project => Project.find(identifier))


Given /^there are the following alternate dates for "([^"]*)":$/ do |scenario_name, table|
  scenario = Scenario.find_by_name!(scenario_name)

  table.map_headers! { |header| header.underscore.gsub(' ', '_') }
  table.hashes.each do |row|
    planning_element = PlanningElement.find_by_subject!(row["planning_element_subject"])
    planning_element.scenarios = {scenario.id.to_s => {"id" => scenario.id.to_s, "start_date" => row["start_date"], "end_date" => row["end_date"]} }
    planning_element.save!
  end
end

Given /^I delete the scenario "([^"]*)"$/ do |scenario_name|
  scenario = Scenario.find_by_name!(scenario_name)
  scenario.destroy
end

# Using our own project creation step to make sure, that we may initially assign
# a project type.
#
Given /^there is a project named "([^"]*)" of type "([^"]*)"$/ do |name, project_type_name|
  FactoryGirl.create(:project,
                 :name                      => name,
                 :project_type_id => ProjectType.find_by_name!(project_type_name).id)
end

Given /^there are the following projects of type "([^"]*)":$/ do |project_type_name, table|
  table.raw.flatten.each do |name|
    step %Q{there is a project named "#{name}" of type "#{project_type_name}"}
  end
end

Given /^the project(?: named "([^"]*)")? has no project type$/ do |name|
  project = get_project(name)
  project.update_attribute(:project_type_id, nil)
end

Given /^there are the following project associations:$/ do |table|
  table.map_headers! { |h| h.delete(' ').underscore }

  table.map_column!('project_a') { |name| Project.find_by_name!(name) }
  table.map_column!('project_b') { |name| Project.find_by_name!(name) }

  table.hashes.each do |type_attributes|
    FactoryGirl.create(:project_association, type_attributes)
  end
end

Given /^there are the following reportings:$/ do |table|
  table.map_headers! { |h| h.delete(' ').underscore }

  table.hashes.each do |attrs|
    attrs['project'] = Project.find_by_name!(attrs["project"])
    attrs['reporting_to_project'] = Project.find_by_name!(attrs["reporting_to_project"])
    FactoryGirl.create(:reporting, attrs)
  end
end

Given /^there is a timeline "([^"]*)" for project "([^"]*)"$/ do |timeline_name, project_name|
  project = Project.find_by_name(project_name)

  timeline = FactoryGirl.create(:timeline, :project_id => project.id, :name => timeline_name)
  timeline.options = {"initial_outline_expansion"=>["6"], "timeframe_end"=>"", "timeframe_start"=>"", "zoom_factor"=>["-1"], "exist"=>""}
  timeline.save!
end


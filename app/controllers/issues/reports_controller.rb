#-- encoding: UTF-8
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

class Issues::ReportsController < ApplicationController
  menu_item :summary_field, :only => [:issue_report]
  before_filter :find_project_by_project_id, :authorize, :find_issue_statuses

  def report
    @types = @project.types
    @versions = @project.shared_versions.sort
    @priorities = IssuePriority.all
    @categories = @project.issue_categories
    @assignees = @project.members.collect { |m| m.user }.sort
    @authors = @project.members.collect { |m| m.user }.sort
    @subprojects = @project.descendants.visible

    @issues_by_type = Issue.by_type(@project)
    @issues_by_version = Issue.by_version(@project)
    @issues_by_priority = Issue.by_priority(@project)
    @issues_by_category = Issue.by_category(@project)
    @issues_by_assigned_to = Issue.by_assigned_to(@project)
    @issues_by_author = Issue.by_author(@project)
    @issues_by_subproject = Issue.by_subproject(@project) || []
  end

  def report_details
    case params[:detail]
    when "type"
      @field = "type_id"
      @rows = @project.types
      @data = Issue.by_type(@project)
      @report_title = Issue.human_attribute_name(:type)
    when "version"
      @field = "fixed_version_id"
      @rows = @project.shared_versions.sort
      @data = Issue.by_version(@project)
      @report_title = Issue.human_attribute_name(:version)
    when "priority"
      @field = "priority_id"
      @rows = IssuePriority.all
      @data = Issue.by_priority(@project)
      @report_title = Issue.human_attribute_name(:priority)
    when "category"
      @field = "category_id"
      @rows = @project.issue_categories
      @data = Issue.by_category(@project)
      @report_title = Issue.human_attribute_name(:category)
    when "assigned_to"
      @field = "assigned_to_id"
      @rows = @project.members.collect { |m| m.user }.sort
      @data = Issue.by_assigned_to(@project)
      @report_title = Issue.human_attribute_name(:assigned_to)
    when "author"
      @field = "author_id"
      @rows = @project.members.collect { |m| m.user }.sort
      @data = Issue.by_author(@project)
      @report_title = Issue.human_attribute_name(:author)
    when "subproject"
      @field = "project_id"
      @rows = @project.descendants.visible
      @data = Issue.by_subproject(@project) || []
      @report_title = l(:label_subproject_plural)
    end

    respond_to do |format|
      if @field
        format.html {}
      else
        format.html { redirect_to report_project_issues_path(@project) }
      end
    end
  end

  private

  def find_issue_statuses
    @statuses = IssueStatus.find(:all, :order => 'position')
  end

  def default_breadcrumb
    l(:label_summary)
  end
end

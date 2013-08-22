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

class WorkflowsController < ApplicationController
  layout 'admin'

  before_filter :require_admin
  before_filter :find_roles
  before_filter :find_types

  def index
    @workflow_counts = Workflow.count_by_type_and_role
  end

  def edit
    @role = Role.find_by_id(params[:role_id])
    @type = Type.find_by_id(params[:type_id])

    if request.post?
      Workflow.destroy_all( ["role_id=? and type_id=?", @role.id, @type.id])
      (params[:issue_status] || []).each { |status_id, transitions|
        transitions.each { |new_status_id, options|
          author = options.is_a?(Array) && options.include?('author') && !options.include?('always')
          assignee = options.is_a?(Array) && options.include?('assignee') && !options.include?('always')
          @role.workflows.build(:type_id => @type.id, :old_status_id => status_id, :new_status_id => new_status_id, :author => author, :assignee => assignee)
        }
      }
      if @role.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'edit', :role_id => @role, :type_id => @type
        return
      end
    end

    @used_statuses_only = (params[:used_statuses_only] == '0' ? false : true)
    if @type && @used_statuses_only && @type.issue_statuses.any?
      @statuses = @type.issue_statuses
    end
    @statuses ||= IssueStatus.find(:all, :order => 'position')

    if @type && @role && @statuses.any?
      workflows = Workflow.all(:conditions => {:role_id => @role.id, :type_id => @type.id})
      @workflows = {}
      @workflows['always'] = workflows.select {|w| !w.author && !w.assignee}
      @workflows['author'] = workflows.select {|w| w.author}
      @workflows['assignee'] = workflows.select {|w| w.assignee}
    end
  end

  def copy

    if params[:source_type_id].blank? || params[:source_type_id] == 'any'
      @source_type = nil
    else
      @source_type = Type.find_by_id(params[:source_type_id].to_i)
    end
    if params[:source_role_id].blank? || params[:source_role_id] == 'any'
      @source_role = nil
    else
      @source_role = Role.find_by_id(params[:source_role_id].to_i)
    end

    @target_types = params[:target_type_ids].blank? ? nil : Type.find_all_by_id(params[:target_type_ids])
    @target_roles = params[:target_role_ids].blank? ? nil : Role.find_all_by_id(params[:target_role_ids])

    if request.post?
      if params[:source_type_id].blank? || params[:source_role_id].blank? || (@source_type.nil? && @source_role.nil?)
        flash.now[:error] = l(:error_workflow_copy_source)
      elsif @target_types.nil? || @target_roles.nil?
        flash.now[:error] = l(:error_workflow_copy_target)
      else
        Workflow.copy(@source_type, @source_role, @target_types, @target_roles)
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'copy', :source_type_id => @source_type, :source_role_id => @source_role
      end
    end
  end

  private

  def find_roles
    @roles = Role.find(:all, :order => 'builtin, position')
  end

  def find_types
    @types = Type.find(:all, :order => 'position')
  end
end

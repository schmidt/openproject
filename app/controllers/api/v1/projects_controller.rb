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

module Api
  module V1

    class ProjectsController < ProjectsController

      include ::Api::V1::ApiController

      include PaginationHelper

      def index
        @projects = Project.visible.order('lft')
                                   .page(page_param)
                                   .per_page(per_page_param)

        respond_to do |format|
          format.api
        end
      end

      def show
        @users_by_role = @project.users_by_role
        @subprojects = @project.children.visible.all
        @news = @project.news.find(:all, :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")
        @types = @project.rolled_up_types

        cond = @project.project_condition(Setting.display_subprojects_issues?)

        @open_issues_by_type = Issue.visible.count(:group => :type,
                                                :include => [:project, :status, :type],
                                                :conditions => ["(#{cond}) AND #{IssueStatus.table_name}.is_closed=?", false])
        @total_issues_by_type = Issue.visible.count(:group => :type,
                                                :include => [:project, :status, :type],
                                                :conditions => cond)

        if User.current.allowed_to?(:view_time_entries, @project)
          @total_hours = TimeEntry.visible.sum(:hours, :include => :project, :conditions => cond).to_f
        end

        respond_to do |format|
          format.api
        end
      end

      def level_list
        respond_to do |format|
          format.api {
            @elements = Project.project_level_list(Project.visible)
          }
        end
      end

      def update
        @project.safe_attributes = params[:project]
        if validate_parent_id && @project.save
          @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
          respond_to do |format|
            format.api { head :ok }
          end
        else
          respond_to do |format|
            format.api { render_validation_errors(@project) }
          end
        end
      end

      def destroy
        @project_to_destroy = @project
        @project_to_destroy.destroy

        respond_to do |format|
          format.api  { head :ok }
        end
      end

      def create
        @issue_custom_fields = WorkPackageCustomField.find(:all, :order => "#{CustomField.table_name}.position")
        @types = Type.all
        @project = Project.new
        @project.safe_attributes = params[:project]

        if validate_parent_id && @project.save
          @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
          add_current_user_to_project_if_not_admin(@project)
          respond_to do |format|
            format.api  { render :action => 'show', :status => :created, :location => url_for(:controller => '/projects', :action => 'show', :id => @project.id) }
          end
        else
          respond_to do |format|
            format.api  { render_validation_errors(@project) }
          end
        end
      end

    end
  end
end

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

class BoardsController < ApplicationController
  default_search_scope :messages
  before_filter :find_project, :find_board_if_available, :authorize
  accept_key_auth :index, :show

  include MessagesHelper
  include SortHelper
  include WatchersHelper
  include PaginationHelper

  def index
    @boards = @project.boards
    render_404 if @boards.empty?
    # show the board if there is only one
    if @boards.size == 1
      @board = @boards.first
      show
    end
  end

  def show
    respond_to do |format|
      format.html {
        sort_init 'updated_on', 'desc'
        sort_update	'created_on' => "#{Message.table_name}.created_on",
                    'replies' => "#{Message.table_name}.replies_count",
                    'updated_on' => "#{Message.table_name}.updated_on"

        @topics =  @board.topics.order(["#{Message.table_name}.sticky DESC", sort_clause].compact.join(', '))
                                .includes(:author, { :last_reply => :author })
                                .page(params[:page])
                                .per_page(per_page_param)

        @message = Message.new
        render :action => 'show', :layout => !request.xhr?
      }
      format.atom {
        @messages = @board.messages.order('created_on DESC')
                                   .includes(:author, :board)
                                   .limit(Setting.feeds_limit.to_i)

        render_feed(@messages, :title => "#{@project}: #{@board}")
      }
    end
  end

  def new
  end

  def create
    @board = Board.new(params[:board])
    @board.project = @project
    if @board.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to_settings_in_projects
    end
  end

  def edit
  end

  def update
    if @board.update_attributes(params[:board])
      redirect_to_settings_in_projects
    end
  end

  def destroy
    @board.destroy
    redirect_to_settings_in_projects
  end

private
  def redirect_to_settings_in_projects
    redirect_to :controller => '/projects', :action => 'settings', :id => @project, :tab => 'boards'
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_board_if_available
    @board = @project.boards.find(params[:id]) if params[:id]
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end

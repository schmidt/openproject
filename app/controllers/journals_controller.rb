# This file is part of the acts_as_journalized plugin for the redMine
# project management software
#
# Copyright (C) 2006-2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either journal 2
# of the License, or (at your option) any later journal.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class JournalsController < ApplicationController
  unloadable
  before_filter :find_journal, :only => [:edit]
  before_filter :find_optional_project, :only => [:index]
  accept_key_auth :index
  
  helper :issues
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
  helper :custom_fields
  
  def index
    retrieve_query
    sort_init 'id', 'desc'
    sort_update(@query.sortable_columns)
    
    if @query.valid?
      @journals = @query.issue_journals(:order => "#{Journal.table_name}.created_at DESC",
                                        :limit => 25)
    end
    puts @journals.inspect
    @title = (@project ? @project.name : Setting.app_title) + ": " + (@query.new_record? ? l(:label_changes_details) : @query.name)
    render :layout => false, :content_type => 'application/atom+xml'
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def edit
    if request.post?
      @journal.update_attribute(:notes, params[:notes]) if params[:notes]
      @journal.destroy if @journal.details.empty? && @journal.notes.blank?
      call_hook(:controller_journals_edit_post, { :journal => @journal, :params => params})
      respond_to do |format|
        format.html { redirect_to :controller => @journal.journaled.class.name.pluralize.downcase,
            :action => 'show', :id => @journal.journaled_id }
        format.js { render :action => 'update' }
      end
    end
  end

private
  def find_journal
    @journal = Journal.find(params[:id])
    (render_403; return false) unless @journal.editable_by?(User.current)
    @project = @journal.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
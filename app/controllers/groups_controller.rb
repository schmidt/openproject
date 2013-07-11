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

class GroupsController < ApplicationController
  layout 'admin'

  before_filter :require_admin
  before_filter :find_group, :only => [:destroy, :autocomplete_for_user, :show]


  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.order('lastname ASC').all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id], :include => [ :users, :memberships ])
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = l(:notice_successful_create)
        format.html { redirect_to(groups_path) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id], :include => :users)

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = l(:notice_successful_update)
        format.html { redirect_to(groups_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end

  def add_users
    @group = Group.find(params[:id], :include => :users )
    @users = User.find_all_by_id(params[:user_ids], :include => :memberships)
    @group.users << @users
    respond_to do |format|
      format.html { redirect_to :controller => '/groups', :action => 'edit', :id => @group, :tab => 'users' }
      format.js { render :action => 'change_members' }
    end
  end

  def remove_user
    @group = Group.find(params[:id], :include => :users)
    @group.users.delete(User.find(params[:user_id], :include => :memberships))
    respond_to do |format|
      format.html { redirect_to :controller => '/groups', :action => 'edit', :id => @group, :tab => 'users' }
      format.js { render :action => 'change_members' }
    end
  end

  def autocomplete_for_user
    @users = User.active.not_in_group(@group).like(params[:q]).all(:limit => 100)
    render :layout => false
  end

  def create_memberships
    @group = Group.find(params[:id])
    @membership = Member.edit_membership(params[:membership_id], params[:membership], @group)
    @membership.save

    respond_to do |format|
      format.html { redirect_to :controller => '/groups', :action => 'edit', :id => @group, :tab => 'memberships' }
      format.js { render :action => 'change_memberships' }
    end
  end

  alias :edit_membership :create_memberships

  def destroy_membership
    Member.find(params[:membership_id]).destroy
    @group = Group.find(params[:id])
    respond_to do |format|
      format.html { redirect_to :controller => '/groups', :action => 'edit', :id => @group, :tab => 'memberships' }
      format.js { render :action => 'destroy_memberships' }
    end
  end

  protected

  def find_group
    @group = Group.find(params[:id])
  end
end

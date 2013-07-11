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
require File.expand_path('../../test_helper', __FILE__)

class MemberTest < ActiveSupport::TestCase
  def setup
    super
    Role.non_member.add_permission! :view_work_packages # non_member users may be watchers of work units
    Role.non_member.add_permission! :view_wiki_pages # non_member users may be watchers of wikis
    @project = FactoryGirl.create :project_with_trackers
    @user = FactoryGirl.create :user, :member_in_project => @project
    @member = @project.members.first
    @role = @member.roles.first
    @role.add_permission! :view_wiki_pages
  end

  def test_create
    member = Member.new.tap do |m|
      m.force_attributes = { :project_id => @project.id,
                             :user_id => FactoryGirl.create(:user).id,
                             :role_ids => [@role.id] }
    end
    assert member.save
    member.reload

    assert_equal 1, member.roles.size
    assert_equal @role, member.roles.first
  end

  def test_update
    assert_equal @project.name, @member.project.name
    assert_equal @role.name, @member.roles.first.name
    assert_equal @user.login, @member.user.login

    @member.mail_notification = !@member.mail_notification
    assert @member.save
  end

  def test_update_roles
    assert_equal 1, @member.roles.size
    @member.role_ids = [@role.id, FactoryGirl.create(:role).id]
    assert @member.save
    assert_equal 2, @member.reload.roles.size
  end

  def test_validate
    members = []
    user_id = FactoryGirl.create(:user).id
    2.times do
      members << Member.new.tap do |m|
        m.force_attributes = { :project_id => @project.id,
                               :user_id => user_id,
                               :role_ids => [@role.id] }
      end
    end

    assert members.first.save
    # same user can't have more than one membership for a project
    assert !members.last.save

    member = Member.new.tap do |m|
      m.force_attributes = { :project_id => @project,
                             :user_id => FactoryGirl.create(:user).id,
                             :role_ids => [] }
    end
    # must have one role at least
    assert !member.save
  end

  def test_destroy
    assert_difference 'Member.count', -1 do
      assert_difference 'MemberRole.count', -1 do
        @member.destroy
      end
    end

    assert_raise(ActiveRecord::RecordNotFound) { Member.find(@member.id) }
  end

  context "removing permissions" do
    setup do
      @private_project = FactoryGirl.create :project_with_trackers,
        :is_public => true # has to be public first to successfully create things. Will be set to private later
      @watcher_user = FactoryGirl.create(:user)

      # watchers for public issue
      public_issue = FactoryGirl.create :issue
      public_issue.project.is_public = true
      public_issue.project.save!
      Watcher.create!(:watchable => public_issue, :user => @watcher_user)

      # watchers for private things
      Watcher.create!(:watchable => FactoryGirl.create(:issue, :project => @private_project), :user => @watcher_user)
      board = FactoryGirl.create :board, :project => @private_project
      @message = FactoryGirl.create :message, :board => board
      Watcher.create!(:watchable => @message, :user => @watcher_user)
      Watcher.create!(:watchable => FactoryGirl.create(:wiki, :project => @private_project), :user => @watcher_user)
      @private_project.reload # to access @private_project.wiki
      Watcher.create!(:watchable => FactoryGirl.create(:wiki_page, :wiki => @private_project.wiki), :user => @watcher_user)
      @private_role = FactoryGirl.create :role, :permissions => [:view_wiki_pages, :view_work_packages]

      @private_project.is_public = false
      @private_project.save
    end

    context "of user" do
      setup do
        (@member = Member.new.tap do |m|
          m.force_attributes = { :project_id => @private_project.id,
                                 :user_id => @watcher_user.id,
                                 :role_ids => [@private_role.id, FactoryGirl.create(:role).id] }
        end).save!
      end

      context "by deleting membership" do
        should "prune watchers" do
          assert_difference 'Watcher.count', -4 do
            @member.destroy
          end
        end
      end

      context "by updating roles" do
        should "prune watchers" do
          @private_role.remove_permission! :view_wiki_pages
          assert_difference 'Watcher.count', -2 do
            @member.role_ids = [@private_role.id]
            @member.save
          end
          assert !@message.watched_by?(@watcher_user)
        end
      end
    end

    context "of group" do
      setup do
        @group = FactoryGirl.create :group
        @member = (Member.new.tap do |m|
          m.force_attributes = { :project_id => @private_project.id,
                                 :user_id => @group.id,
                                 :role_ids => [@private_role.id, FactoryGirl.create(:role).id] }
        end)

        @group.members << @member
        @group.users << @watcher_user
        assert @group.save
      end

      context "by deleting membership" do
        should "prune watchers" do
          assert_difference 'Watcher.count', -4 do
            @member.destroy
          end
        end
      end

      context "by updating roles" do
        should "prune watchers" do
          @private_role.remove_permission! :view_wiki_pages
          assert_difference 'Watcher.count', -2 do
            @member.role_ids = [@private_role.id]
            @member.save
          end
        end
      end
    end
  end
end

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
require 'test_helper'

class WatcherTest < ActiveSupport::TestCase
  def setup
    super
    @user  = FactoryGirl.create :user
    @issue = FactoryGirl.create :issue
    @role  = FactoryGirl.create :role, :permissions => [:view_work_packages]
    @issue.project.add_member! @user, @role
  end

  def test_add_watcher
    @issue.add_watcher(@user)
    assert_contains @issue.watchers.map(&:user), @user
  end

  def test_add_watcher_will_not_add_same_user_twice
    assert @issue.add_watcher(@user)
    refute @issue.add_watcher(@user)
  end

  def test_watched_by
    @issue.add_watcher(@user)
    assert @issue.watched_by?(@user)
    assert_contains Issue.watched_by(@user), @issue
  end

  def test_watcher_users_contains_correct_classes
    @issue.add_watcher(@user)
    watcher_users = @issue.watcher_users
    assert_kind_of Array, watcher_users
    assert_kind_of User, watcher_users.first
  end

  def test_watcher_users_should_not_validate_user
    @user.stubs(:valid?).returns(false)
    @issue.watcher_users << @user
    assert @issue.watched_by?(@user)
  end

  def test_watcher_user_ids
    @issue.add_watcher(@user)
    assert_contains @issue.watcher_user_ids, @user.id
  end

  def test_watcher_user_ids=
    @issue.watcher_user_ids = [@user.id]
    assert @issue.watched_by?(@user)
  end

  def test_watcher_user_ids_should_make_ids_uniq
    @issue.watcher_user_ids = [@user.id, @user.id]
    assert @issue.valid?
    assert_equal 1, @issue.watchers.count
  end

  def test_addable_watcher_users
    addable_watcher_users = @issue.addable_watcher_users
    assert_kind_of Array, addable_watcher_users
    assert_kind_of User, addable_watcher_users.first
  end

  def test_recipients
    @user.update_attribute :mail_notification, 'all'

    assert @issue.watcher_recipients.empty?
    assert @issue.add_watcher(@user)
    assert_contains @issue.watcher_recipients, @user.mail

    @user.update_attribute :mail_notification, 'none'
    assert_does_not_contain @issue.watcher_recipients, @user.mail
  end

  def test_unwatch
    assert @issue.add_watcher(@user)
    assert_equal 1, @issue.remove_watcher(@user)
    refute @issue.watched_by?(@user)
  end

  def test_prune_removes_watchers_that_dont_have_permission
    @issue.add_watcher(@user)

    assert_no_difference 'Watcher.count' do
      Watcher.prune(:user => @user)
    end
    assert @issue.watched_by?(@user)

    Member.delete_all
    @user.reload

    assert_difference 'Watcher.count', -1 do
      Watcher.prune(:user => @user)
    end
    refute @issue.watched_by?(@user)
  end
end

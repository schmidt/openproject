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

class ActivityTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    super
    @project = Project.find(1)
    [1,4,5,6].each do |issue_id|
      i = Issue.find(issue_id)
      i.init_journal(User.current, "A journal to find")
      i.save!
    end
  end

  def test_activity_without_subprojects
    events = find_events(User.anonymous, :project => @project)
    assert_not_nil events

    assert events.include?(Issue.find(1))
    assert !events.include?(Issue.find(4))
    # subproject issue
    assert !events.include?(Issue.find(5))
  end

  def test_activity_with_subprojects
    events = find_events(User.anonymous, :project => @project, :with_subprojects => 1)
    assert_not_nil events

    assert events.include?(Issue.find(1))
    # subproject issue
    assert events.include?(Issue.find(5))
  end

  def test_global_activity_anonymous
    events = find_events(User.anonymous)
    assert_not_nil events

    assert events.include?(Issue.find(1))
    assert events.include?(Message.find(5))
    # Issue of a private project
    assert !events.include?(Issue.find(6))
  end

  def test_global_activity_logged_user
    events = find_events(User.find(2)) # manager
    assert_not_nil events

    assert events.include?(Issue.find(1))
    # Issue of a private project the user belongs to
    assert events.include?(Issue.find(6))
  end

  def test_user_activity
    user = User.find(2)
    events = Redmine::Activity::Fetcher.new(User.anonymous, :author => user).events(nil, nil, :limit => 10)

    assert(events.size > 0)
    assert(events.size <= 10)
    assert_nil(events.detect {|e| e.event_author != user})
  end

  def test_files_activity
    f = Redmine::Activity::Fetcher.new(User.anonymous, :project => Project.find(1))
    f.scope = ['files']
    events = f.events

    assert_kind_of Array, events
    assert events.include?(Attachment.find_by_container_type_and_container_id('Project', 1).last_journal)
    assert events.include?(Attachment.find_by_container_type_and_container_id_and_id('Version', 1, 9).last_journal)
    assert_equal [Attachment], events.collect(&:journaled).collect(&:class).uniq
    assert_equal %w(Project Version), events.collect(&:journaled).collect(&:container_type).uniq.sort
  end

  private

  def find_events(user, options={})
    events = Redmine::Activity::Fetcher.new(user, options).events(Date.today - 30, Date.today + 1)
    # Because events are provided by the journals, but we want to test for
    # their targets here, transform that
    events.group_by(&:journaled).keys
  end
end

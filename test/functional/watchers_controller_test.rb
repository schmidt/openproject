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
require 'watchers_controller'

# Re-raise errors caught by the controller.
class WatchersController; def rescue_action(e) raise e end; end

class WatchersControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    super
    @controller = WatchersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_watch
    @request.session[:user_id] = 3
    assert_difference('Watcher.count') do
      xhr :post, :watch, :object_type => 'issue', :object_id => '1'
      assert_response :success
      assert @response.body.include? "$$(\"#watcher\").each"
      assert @response.body.include? "value.replace"
    end
    assert Issue.find(1).watched_by?(User.find(3))
  end

  def test_watch_should_be_denied_without_permission
    Role.find(2).remove_permission! :view_work_packages
    @request.session[:user_id] = 3
    assert_no_difference('Watcher.count') do
      xhr :post, :watch, :object_type => 'issue', :object_id => '1'
      assert_response 403
    end
  end

  def test_watch_with_multiple_replacements
    @request.session[:user_id] = 3
    assert_difference('Watcher.count') do
      xhr :post, :watch, :object_type => 'issue', :object_id => '1', :replace => ['#watch_item_1','.watch_item_2']
      assert_response :success
      assert @response.body.include? "$$(\"#watch_item_1\").each"
      assert @response.body.include? "$$(\".watch_item_2\").each"
      assert @response.body.include? "value.replace"
    end
  end

  def test_watch_with_watchers_special_logic
    @request.session[:user_id] = 3
    assert_difference('Watcher.count') do
      xhr :post, :watch, :object_type => 'issue', :object_id => '1', :replace => ['#watchers', '.watcher']
      assert_response :success
      assert_select_rjs :replace_html, 'watchers'
      assert @response.body.include? "$$(\".watcher\").each"
      assert @response.body.include? "value.replace"
    end
  end

  def test_unwatch
    @request.session[:user_id] = 3
    assert_difference('Watcher.count', -1) do
      xhr :post, :unwatch, :object_type => 'issue', :object_id => '2'
      assert_response :success
      assert @response.body.include? "$$(\"#watcher\").each"
      assert @response.body.include? "value.replace"
    end
    assert !Issue.find(1).watched_by?(User.find(3))
  end

  def test_unwatch_with_multiple_replacements
    @request.session[:user_id] = 3
    assert_difference('Watcher.count', -1) do
      xhr :post, :unwatch, :object_type => 'issue', :object_id => '2', :replace => ['#watch_item_1', '.watch_item_2']
      assert_response :success
      assert @response.body.include? "$$(\"#watch_item_1\").each"
      assert @response.body.include? "$$(\".watch_item_2\").each"
      assert @response.body.include? "value.replace"
    end
    assert !Issue.find(1).watched_by?(User.find(3))
  end

  def test_unwatch_with_watchers_special_logic
    @request.session[:user_id] = 3
    assert_difference('Watcher.count', -1) do
      xhr :post, :unwatch, :object_type => 'issue', :object_id => '2', :replace => ['#watchers', '.watcher']
      assert_response :success
      assert_select_rjs :replace_html, 'watchers'
      assert @response.body.include? "$$(\".watcher\").each"
      assert @response.body.include? "value.replace"
    end
    assert !Issue.find(1).watched_by?(User.find(3))
  end

  def test_new_watcher
    Watcher.destroy_all
    @request.session[:user_id] = 2
    assert_difference('Watcher.count') do
      xhr :post, :new, :object_type => 'issue', :object_id => '2', :watcher => {:user_id => '3'}
      assert_response :success
      assert_select_rjs :replace_html, 'watchers'
    end
    assert Issue.find(2).watched_by?(User.find(3))
  end

  def test_remove_watcher
    @request.session[:user_id] = 2
    assert_difference('Watcher.count', -1) do
      xhr :delete, :destroy, :id => Watcher.find_by_user_id_and_watchable_id(3, 2).id
      assert_response :success
      assert_select_rjs :replace_html, 'watchers'
    end
    assert !Issue.find(2).watched_by?(User.find(3))
  end
end

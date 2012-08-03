#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2011 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++
require File.expand_path('../../../../test_helper', __FILE__)

class MenuManagerTest < ActionController::IntegrationTest
  include Redmine::I18n

  fixtures :all

  def test_project_menu_with_specific_locale
    Setting.available_languages = [:fr, :en]
    get 'projects/ecookbook/issues', { }, 'Accept-Language' => 'fr,fr-fr;q=0.8,en-us;q=0.5,en;q=0.3'

    assert_tag :div, :attributes => { :id => 'main-menu' },
                     :descendant => { :tag => 'li', :child => { :tag => 'a', :content => ll('fr', :label_activity),
                                                                             :attributes => { :href => '/projects/ecookbook/activity',
                                                                                              :class => 'activity ellipsis' } } }
    assert_tag :div, :attributes => { :id => 'main-menu' },
                     :descendant => { :tag => 'li', :child => { :tag => 'a', :content => ll('fr', :label_issue_plural),
                                                                             :attributes => { :href => '/projects/ecookbook/issues',
                                                                                              :class => 'issues ellipsis selected' } } }
  end

  def test_project_menu_with_additional_menu_items
    Setting.default_language = 'en'
    assert_no_difference 'Redmine::MenuManager.items(:project_menu).size' do
      Redmine::MenuManager.map :project_menu do |menu|
        menu.push :foo, { :controller => 'projects', :action => 'show' }, :caption => 'Foo'
        menu.push :bar, { :controller => 'projects', :action => 'show' }, :before => :activity
        menu.push :hello, { :controller => 'projects', :action => 'show' }, :caption => Proc.new {|p| p.name.upcase }, :after => :bar
      end

      get 'projects/ecookbook'
      assert_tag :div, :attributes => { :id => 'main-menu' },
                       :descendant => { :tag => 'li', :child => { :tag => 'a', :content => 'Foo',
                                                                               :attributes => { :class => 'foo ellipsis' } } }

      assert_tag :div, :attributes => { :id => 'main-menu' },
                       :descendant => { :tag => 'li', :child => { :tag => 'a', :content => 'Bar',
                                                                               :attributes => { :class => 'bar ellipsis' } },
                                                      :before => { :tag => 'li', :child => { :tag => 'a', :content => 'ECOOKBOOK' } } }

      assert_tag :div, :attributes => { :id => 'main-menu' },
                       :descendant => { :tag => 'li', :child => { :tag => 'a', :content => 'ECOOKBOOK',
                                                                               :attributes => { :class => 'hello ellipsis' } },
                                                      :before => { :tag => 'li', :child => { :tag => 'a', :content => 'Activity' } } }

      # Remove the menu items
      Redmine::MenuManager.map :project_menu do |menu|
        menu.delete :foo
        menu.delete :bar
        menu.delete :hello
      end
    end
  end

  def test_dynamic_menu
    list = []
    Redmine::MenuManager.map :some_menu do |menu|
      list.each do |item|
        menu.push item[:name], item[:url], item[:options]
      end
    end

    base_size = Redmine::MenuManager.items(:some_menu).size
    list.push({ :name => :foo, :url => {:controller => 'projects', :action => 'show'}, :options => {:caption => 'Foo'}})
    assert_equal base_size + 1, Redmine::MenuManager.items(:some_menu).size
    list.push({ :name => :bar, :url => {:controller => 'projects', :action => 'show'}, :options => {:caption => 'Bar'}})
    assert_equal base_size + 2, Redmine::MenuManager.items(:some_menu).size
    list.push({ :name => :hello, :url => {:controller => 'projects', :action => 'show'}, :options => {:caption => 'Hello'}})
    assert_equal base_size + 3, Redmine::MenuManager.items(:some_menu).size
    list.pop
    assert_equal base_size + 2, Redmine::MenuManager.items(:some_menu).size
  end

  def test_dynamic_menu_map_deferred
    assert_no_difference 'Redmine::MenuManager.items(:some_menu).size' do
      Redmine::MenuManager.map(:some_other_menu).push :baz, {:controller => 'projects', :action => 'show'}, :caption => 'Baz'
      Redmine::MenuManager.map(:some_other_menu).delete :baz
    end
  end
end

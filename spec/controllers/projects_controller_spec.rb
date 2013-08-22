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

require 'spec_helper'

describe ProjectsController do
  before do
    Role.delete_all
    User.delete_all
  end

  before do
    @controller.stub!(:set_localization)

    @role = FactoryGirl.create(:non_member)
    @user = FactoryGirl.create(:admin)
    User.stub!(:current).and_return @user

    @params = {}
  end

  def clear_settings_cache
    Rails.cache.clear
  end

  # this is the base method for get, post, etc.
  def process(*args)
    clear_settings_cache
    result = super
    clear_settings_cache
    result
  end

  describe 'show' do
    render_views

    describe 'without wiki' do
      before do
        @project = FactoryGirl.create(:project)
        @project.reload # project contains wiki by default
        @project.wiki.destroy
        @project.reload
        @params[:id] = @project.id
      end

      it 'renders show' do
        get 'show', @params
        response.should be_success
        response.should render_template 'show'
      end

      it 'renders main menu without wiki menu item' do
        get 'show', @params

        assert_select "#main-menu a.Wiki", false # assert_no_select
      end
    end

    describe 'with wiki' do
      before do
        @project = FactoryGirl.create(:project)
        @project.reload # project contains wiki by default
        @params[:id] = @project.id
      end

      describe 'without custom wiki menu items' do
        it 'renders show' do
          get 'show', @params
          response.should be_success
          response.should render_template 'show'
        end

        it 'renders main menu with wiki menu item' do
          get 'show', @params

          assert_select "#main-menu a.Wiki", 'Wiki'
        end
      end

      describe 'with custom wiki menu item' do
        before do
          main_item = FactoryGirl.create(:wiki_menu_item, :wiki_id => @project.wiki.id, :name => 'Example', :title => 'Example')
          sub_item = FactoryGirl.create(:wiki_menu_item, :wiki_id => @project.wiki.id, :name => 'Sub', :title => 'Sub', :parent_id => main_item.id)
        end

        it 'renders show' do
          get 'show', @params
          response.should be_success
          response.should render_template 'show'
        end

        it 'renders main menu with wiki menu item' do
          get 'show', @params

          assert_select "#main-menu a.Example", 'Example'
        end

        it 'renders main menu with sub wiki menu item' do
          get 'show', @params

          assert_select "#main-menu a.Sub", 'Sub'
        end
      end
    end

    describe 'with activated activity module' do
      before do
        @project = FactoryGirl.create(:project, :enabled_module_names => %w[activity])
        @params[:id] = @project.id
      end

      it 'renders show' do
        get 'show', @params
        response.should be_success
        response.should render_template 'show'
      end

      it 'renders main menu with activity tab' do
        get 'show', @params
        assert_select '#main-menu a.activity'
      end
    end

    describe 'without activated activity module' do
      before do
        @project = FactoryGirl.create(:project, :enabled_module_names => %w[wiki])
        @params[:id] = @project.id
      end

      it 'renders show' do
        get 'show', @params
        response.should be_success
        response.should render_template 'show'
      end

      it 'renders main menu without activity tab' do
        get 'show', @params
        response.body.should_not have_selector '#main-menu a.activity'
      end
    end
  end

  describe 'new' do
    render_views

    before(:all) do
      @previous_projects_modules = Setting.default_projects_modules
    end

    after(:all) do
      Setting.default_projects_modules = @previous_projects_modules
    end

    describe 'with activity in Setting.default_projects_modules' do
      before do
        Setting.default_projects_modules = %w[activity wiki]
      end

      it "renders 'new'" do
        get 'new', @params
        response.should be_success
        response.should render_template 'new'
      end

      it 'renders available modules list with activity being selected' do
        get 'new', @params

        response.body.should have_selector "input[@name='project[enabled_module_names][]'][@value='activity'][@checked='checked']"
        response.body.should have_selector "input[@name='project[enabled_module_names][]'][@value='wiki'][@checked='checked']"
      end
    end

    describe 'without activated activity module' do
      before do
        Setting.default_projects_modules = %w[wiki]
      end

      it "renders 'new'" do
        get 'new', @params
        response.should be_success
        response.should render_template 'new'
      end

      it 'renders available modules list without activity being selected' do
        get 'new', @params

        response.body.should have_selector "input[@name='project[enabled_module_names][]'][@value='wiki'][@checked='checked']"
        response.body.should have_selector "input[@name='project[enabled_module_names][]'][@value='activity']"
        response.body.should_not have_selector "input[@name='project[enabled_module_names][]'][@value='activity'][@checked='checked']"
      end
    end
  end

  describe 'settings' do
    render_views

    describe 'with activity in Setting.default_projects_modules' do
      before do
        @project = FactoryGirl.create(:project, :enabled_module_names => %w[activity wiki])
        @params[:id] = @project.id
      end

      it 'renders settings/modules' do
        get 'settings', @params.merge(:tab => 'modules')
        response.should be_success
        response.should render_template 'settings'
      end

      it 'renders available modules list with activity being selected' do
        get 'settings', @params.merge(:tab => 'modules')
        response.body.should have_selector "#modules-form input[@name='enabled_module_names[]'][@value='activity'][@checked='checked']"
        response.body.should have_selector "#modules-form input[@name='enabled_module_names[]'][@value='wiki'][@checked='checked']"
      end
    end

    describe 'without activated activity module' do
      before do
        @project = FactoryGirl.create(:project, :enabled_module_names => %w[wiki])
        @params[:id] = @project.id
      end

      it 'renders settings/modules' do
        get 'settings', @params.merge(:tab => 'modules')
        response.should be_success
        response.should render_template 'settings'
      end

      it 'renders available modules list without activity being selected' do
        get 'settings', @params.merge(:tab => 'modules')

        response.body.should have_selector "#modules-form input[@name='enabled_module_names[]'][@value='wiki'][@checked='checked']"
        response.body.should have_selector "#modules-form input[@name='enabled_module_names[]'][@value='activity']"
        response.body.should_not have_selector "#modules-form input[@name='enabled_module_names[]'][@value='activity'][@checked='checked']"
      end
    end
  end
end

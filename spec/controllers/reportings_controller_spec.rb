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

require File.expand_path('../../spec_helper', __FILE__)

describe ReportingsController do
  let(:current_user) { FactoryGirl.create(:admin) }

  before do
    User.stub(:current).and_return current_user
  end

  describe 'index.html' do
    let(:project) { FactoryGirl.create(:project, :is_public => false) }
    def fetch
      get 'index', :project_id => project.identifier
    end
    let(:permission) { :view_reportings }
    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'show.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:reporting) { FactoryGirl.create(:reporting, :project_id => project.id) }
    def fetch
      get 'show', :project_id => project.identifier, :id => reporting.id
    end
    let(:permission) { :view_reportings }
    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'new.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    def fetch
      FactoryGirl.create(:project, :is_public => true) # reporting candidate

      get 'new', :project_id => project.identifier
    end
    let(:permission) { :edit_reportings }
    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'create.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    def fetch
      post 'create', :project_id => project.identifier,
                     :reporting  => FactoryGirl.build(:reporting,
                     :project_id => project.id).attributes
    end
    let(:permission) { :edit_reportings }
    def expect_redirect_to
      project_reportings_path(project)
    end
    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'edit.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:reporting) { FactoryGirl.create(:reporting, :project_id => project.id) }

    def fetch
      get 'edit', :project_id => project.identifier,
                  :id         => reporting.id
    end
    let(:permission) { :edit_reportings }
    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'update.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:reporting) { FactoryGirl.create(:reporting, :project_id => project.id) }

    def fetch
      post 'update', :project_id => project.identifier,
                     :id         => reporting.id,
                     :reporting => {}
    end
    let(:permission) { :edit_reportings }
    def expect_redirect_to
      project_reportings_path(project)
    end
    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'confirm_destroy.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:reporting) { FactoryGirl.create(:reporting, :project_id => project.id) }

    def fetch
      get 'confirm_destroy', :project_id => project.identifier,
                             :id         => reporting.id
    end
    let(:permission) { :delete_reportings }
    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'update.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:reporting) { FactoryGirl.create(:reporting, :project_id => project.id) }

    def fetch
      post 'destroy', :project_id => project.identifier,
                      :id         => reporting.id
    end
    let(:permission) { :delete_reportings }
    def expect_redirect_to
      project_reportings_path(project)
    end
    it_should_behave_like "a controller action which needs project permissions"
  end
end

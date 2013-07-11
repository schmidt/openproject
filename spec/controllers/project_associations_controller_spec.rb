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

describe ProjectAssociationsController do
  let(:current_user) { FactoryGirl.create(:admin) }

  before do
    User.stub(:current).and_return current_user
  end

  describe 'index.html' do
    let(:project) { FactoryGirl.create(:project, :is_public => false) }
    def fetch
      get 'index', :project_id => project.identifier
    end
    let(:permission) { :view_project_associations }

    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'new.html' do
    let(:project) { FactoryGirl.create(:project, :is_public => false) }
    def fetch
      get 'new', :project_id => project.identifier
    end
    let(:permission) { :edit_project_associations }

    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'create.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:project_b) { FactoryGirl.create(:project, :is_public => true) }
    def fetch
      post 'create', :project_id => project.identifier,
                     :project_association => {},
                     :project_association_select => {:project_b_id => project_b.id}
    end
    let(:permission) { :edit_project_associations }
    def expect_redirect_to
      Regexp.new(project_project_associations_path(project))
    end

    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'edit.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:project_b) { FactoryGirl.create(:project, :is_public => true) }
    let(:project_association) { FactoryGirl.create(:project_association,
                                               :project_a_id => project.id,
                                               :project_b_id => project_b.id) }
    def fetch
      get 'edit', :project_id => project.identifier,
                  :id         => project_association.id
    end
    let(:permission) { :edit_project_associations }

    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'update.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:project_b) { FactoryGirl.create(:project, :is_public => true) }
    let(:project_association) { FactoryGirl.create(:project_association,
                                               :project_a_id => project.id,
                                               :project_b_id => project_b.id) }
    def fetch
      post 'update', :project_id => project.identifier,
                     :id         => project_association.id,
                     :project_association => {}
    end
    let(:permission) { :edit_project_associations }
    def expect_redirect_to
      project_project_associations_path(project)
    end

    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'confirm_destroy.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:project_b) { FactoryGirl.create(:project, :is_public => true) }
    let(:project_association) { FactoryGirl.create(:project_association,
                                               :project_a_id => project.id,
                                               :project_b_id => project_b.id) }
    def fetch
      get 'confirm_destroy', :project_id => project.identifier,
                             :id         => project_association.id,
                             :project_association => {}
    end
    let(:permission) { :delete_project_associations }

    it_should_behave_like "a controller action which needs project permissions"
  end

  describe 'destroy.html' do
    let(:project)   { FactoryGirl.create(:project, :is_public => false) }
    let(:project_b) { FactoryGirl.create(:project, :is_public => true) }
    let(:project_association) { FactoryGirl.create(:project_association,
                                               :project_a_id => project.id,
                                               :project_b_id => project_b.id) }
    def fetch
      post 'destroy', :project_id => project.identifier,
                      :id         => project_association.id
    end
    let(:permission) { :delete_project_associations }
    def expect_redirect_to
      project_project_associations_path(project)
    end

    it_should_behave_like "a controller action which needs project permissions"
  end
end

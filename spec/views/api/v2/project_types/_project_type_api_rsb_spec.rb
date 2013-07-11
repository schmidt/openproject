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

require File.expand_path('../../../../../spec_helper', __FILE__)

describe 'api/v2/project_types/_project_type.api' do
  before do
    view.extend TimelinesHelper
  end

  # added to pass in locals
  def render
    params[:format] = 'xml'
    super(:partial => 'api/v2/project_types/project_type.api', :object => project_type)
  end

  describe 'with an assigned project_type' do
    let(:project_type) { FactoryGirl.build(:project_type, :id => 1,
                                                                :name => 'Awesometastic Project Type',
                                                                :allows_association => false,
                                                                :position => 100,
                                                                :created_at => Time.parse('Thu Jan 06 12:35:00 +0100 2011'),
                                                                :updated_at => Time.parse('Fri Jan 07 12:35:00 +0100 2011')) }

    it 'renders a project_type node' do
      render

      response.should have_selector('project_type', :count => 1)
    end

    describe 'project_type node' do
      it 'contains an id element containing the project type id' do
        render

        response.should have_selector('project_type id', :text => '1')
      end

      it 'contains a name element containing the project type name' do
        render

        response.should have_selector('project_type name', :text => 'Awesometastic Project Type')
      end

      it 'contains an allows_association element containing the project type field allows_association' do
        render

        response.should have_selector('project_type allows_association', :text => 'false')
      end

      it 'contains an position element containing the project type position' do
        render

        response.should have_selector('project_type position', :text => '100')
      end

      it 'contains a created_at element containing the project type created_at in UTC in ISO 8601' do
        render

        response.should have_selector('project_type created_at', :text => '2011-01-06T11:35:00Z')
      end

      it 'contains an updated_at element containing the project type updated_at in UTC in ISO 8601' do
        render

        response.should have_selector('project_type updated_at', :text => '2011-01-07T11:35:00Z')
      end
    end
  end
end

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

describe 'api/v2/planning_element_statuses/_planning_element_status.api' do
  before do
    view.extend TimelinesHelper
  end

  # added to pass in locals
  def render
    params[:format] = 'xml'
    super(:partial => 'api/v2/planning_element_statuses/planning_element_status.api', :object => planning_element_status)
  end

  describe 'with an assigned planning_element_status' do
    let(:planning_element_status) { FactoryGirl.build(:planning_element_status,
                                                  :id => 1,
                                                  :name => 'Awesometastic Planning Element Status',
                                                  :position => 100) }

    it 'renders a planning_element_status node' do
      render
      response.should have_selector('planning_element_status', :count => 1)
    end

    describe 'planning_element_status node' do
      it 'contains an id element containing the planning element status id' do
        render
        response.should have_selector('planning_element_status id', :text => '1')
      end

      it 'contains a name element containing the planning element status name' do
        render
        response.should have_selector('planning_element_status name', :text => 'Awesometastic Planning Element Status')
      end

      it 'contains an position element containing the planning element status position' do
        render
        response.should have_selector('planning_element_status position', :text => '100')
      end
    end
  end
end

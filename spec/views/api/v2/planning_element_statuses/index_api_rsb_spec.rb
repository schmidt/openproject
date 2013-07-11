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

describe 'api/v2/planning_element_statuses/index.api.rsb' do
  before do
    view.extend TimelinesHelper
  end

  before do
    params[:format] = 'xml'
  end

  describe 'with no planning element statuses available' do
    it 'renders an empty planning_element_statuses document' do
      assign(:planning_element_statuses, [])

      render

      response.should have_selector('planning_element_statuses', :count => 1)
      response.should have_selector('planning_element_statuses[type=array][size="0"]') do
        without_tag 'planning_element_status'
      end
    end
  end

  describe 'with 3 planning element statuses available' do
    let(:planning_element_statuses) do
      [
        FactoryGirl.build(:planning_element_status),
        FactoryGirl.build(:planning_element_status),
        FactoryGirl.build(:planning_element_status)
      ]
    end

    it 'renders a planning_element_statuses document with the size 3 of type array' do
      assign(:planning_element_statuses, planning_element_statuses)

      render

      response.should have_selector('planning_element_statuses', :count => 1)
      response.should have_selector('planning_element_statuses[type=array][size="3"]')
    end

    it 'renders a planning_element_status for each assigned planning element' do
      assign(:planning_element_statuses, planning_element_statuses)


      render

      response.should have_selector('planning_element_statuses planning_element_status', :count => 3)
    end

    it 'renders the _planning_element_status template for each assigned planning element status' do
      assign(:planning_element_statuses, planning_element_statuses)

      view.should_receive(:render).exactly(3).times.with(hash_including(:partial => '/api/v2/planning_element_statuses/planning_element_status.api')).and_return('')

      # just to be able to call render despite the should_receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/planning_element_statuses/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end

    it 'passes the planning element statuses as local var to the partial' do
      assign(:planning_element_statuses, planning_element_statuses)

      view.should_receive(:render).once.with(hash_including(:object => planning_element_statuses.first)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => planning_element_statuses.second)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => planning_element_statuses.third)).and_return('')

      # just to be able to call render despite the should_receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/planning_element_statuses/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end
  end
end

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

describe 'api/v2/planning_element_statuses/show.api.rsb' do
  before do
    view.extend TimelinesHelper
  end

  before do
    params[:format] = 'xml'
  end

  describe 'with an assigned planning element status' do
    let(:planning_element_status) { FactoryGirl.build(:planning_element_status) }

    before do
      assign(:planning_element_status, planning_element_status)
    end

    it 'renders a planning_element_status document' do

      render

      response.should have_selector('planning_element_status', :count => 1)
    end

    it 'renders the _planning_element_status template once' do

      view.should_receive(:render).once.with(hash_including(:partial => '/api/v2/planning_element_statuses/planning_element_status.api')).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/planning_element_statuses/show", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end

    it 'passes the planning element status as local var to the partial' do

      view.should_receive(:render).once.with(hash_including(:object => planning_element_status)).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/planning_element_statuses/show", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end
  end
end

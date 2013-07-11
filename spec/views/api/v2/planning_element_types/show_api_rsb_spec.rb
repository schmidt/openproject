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

describe 'api/v2/planning_element_types/show.api.rsb' do
  before do
    view.extend TimelinesHelper
  end

  before do
    params[:format] = 'xml'
  end

  describe 'with an assigned planning element type' do
    let(:planning_element_type) { FactoryGirl.build(:planning_element_type) }

    before do
      assign(:planning_element_type, planning_element_type)
    end

    it 'renders a planning_element_type document' do

      render

      response.should have_selector('planning_element_type', :count => 1)
    end

    it 'renders the _planning_element_type template once' do

      view.should_receive(:render).once.with(hash_including(:partial => '/api/v2/planning_element_types/planning_element_type.api')).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/planning_element_types/show", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end

    it 'passes the planning element type as local var to the partial' do

      view.should_receive(:render).once.with(hash_including(:object => planning_element_type)).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/planning_element_types/show", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end
  end
end

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

describe 'api/v2/reportings/index.api.rsb' do
  before do
    view.extend TimelinesHelper
  end

  before do
    params[:format] = 'xml'
  end

  describe 'with no reportings available' do
    it 'renders an empty reportings document' do
      assign(:reportings, [])

      render

      response.should have_selector('reportings', :count => 1)
      response.should have_selector('reportings[type=array][size="0"]') do
        without_tag 'reporting'
      end
    end
  end

  describe 'with 3 reportings available' do
    let(:reportings) do
      [
        FactoryGirl.build(:reporting),
        FactoryGirl.build(:reporting),
        FactoryGirl.build(:reporting)
      ]
    end

    it 'renders a reportings document with the size 3 of array' do
      assign(:reportings, reportings)

      render

      response.should have_selector('reportings', :count => 1)
      response.should have_selector('reportings[type=array][size="3"]')
    end

    it 'renders a reporting for each assigned reporting' do
      assign(:reportings, reportings)

      render

      response.should have_selector('reportings reporting', :count => 3)
    end

    it 'renders the _reporting template for each assigned reporting' do
      assign(:reportings, reportings)

      view.should_receive(:render).exactly(3).times.with(hash_including(:partial => '/api/v2/reportings/reporting.api')).and_return('')

      # just to call the original render despite the should receive expectation
      view.should_receive(:render).once.with({:template=>"api/v2/reportings/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end

    it 'passes the reportings as local var to the partial' do
      assign(:reportings, reportings)

      view.should_receive(:render).once.with(hash_including(:object => reportings.first)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => reportings.second)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => reportings.third)).and_return('')

      # just to call the original render despite the should receive expectation
      view.should_receive(:render).once.with({:template=>"api/v2/reportings/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end
  end
end


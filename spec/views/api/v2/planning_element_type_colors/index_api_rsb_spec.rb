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

describe 'api/v2/planning_element_type_colors/index.api.rsb' do
  before do
    view.extend TimelinesHelper
  end

  before do
    params[:format] = 'xml'
  end

  describe 'with no colors available' do
    it 'renders an empty colors document' do
      assign(:colors, [])

      render

      response.should have_selector('colors', :count => 1)
      response.should have_selector('colors[type=array][size="0"]') do
        without_tag 'color'
      end
    end
  end

  describe 'with 3 colors available' do
    let(:colors) {
      [
        FactoryGirl.build(:color),
        FactoryGirl.build(:color),
        FactoryGirl.build(:color)
      ]
    }

    before do
      assign(:colors, colors)
    end

    it 'renders a colors document with the size 3 of array' do
      render

      response.should have_selector('colors', :count => 1)
      response.should have_selector('colors[type=array][size="3"]')
    end

    it 'renders a color for each assigned color' do

      render

      response.should have_selector('colors color', :count => 3)
    end

    it 'renders the _color template for each assigned color' do

      view.should_receive(:render).exactly(3).times.with(hash_including(:partial => '/api/v2/planning_element_type_colors/color.api')).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/planning_element_type_colors/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end

    it 'passes the colors as local var to the partial' do

      view.should_receive(:render).once.with(hash_including(:object => colors.first)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => colors.second)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => colors.third)).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template => 'api/v2/planning_element_type_colors/index', :handlers=>['rsb'], :formats=>['api']}, {}).and_call_original

      render
    end
  end
end

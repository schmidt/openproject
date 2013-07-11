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

describe 'api/v2/planning_elements/show.api.rsb' do
  before do
    view.extend TimelinesHelper
    view.extend PlanningElementsHelper
  end

  before do
    view.stub(:include_journals?).and_return(false)
    view.stub(:include_scenarios?).and_return(false)
    params[:format] = 'xml'
  end

  let(:planning_element) { FactoryGirl.build(:planning_element) }

  describe 'with an assigned planning element' do
    it 'renders a planning_element document' do
      assign(:planning_element, planning_element)

      render

      response.should have_selector('planning_element', :count => 1)
    end

    it 'calls the render_planning_element helper once' do
      assign(:planning_element, planning_element)

      view.should_receive(:render_planning_element).once.and_return('')

      render
    end

    it 'passes the planning element as local var to the helper' do
      assign(:planning_element, planning_element)

      view.should_receive(:render_planning_element).once.with(anything, planning_element).and_return('')

      render
    end
  end

  describe 'with an assigned planning element
            when requesting journals' do
    before do
      view.stub(:include_journals?).and_return(true)
    end

    let(:journal) { FactoryGirl.build(:planning_element_journal) }
    let(:changes) { { "name" => ["old_name", "new_name"],
                      "project_id" => ["1", "2"],
                      "scenario_1_end_date" => ["2012-01-01", "2013-01-01"] } }
    let(:user) { FactoryGirl.create(:user) }

    it 'countains an array of journals' do
      # prevents problems related to the journal not having a user associated
      User.current = user

      assign(:planning_element, journal.journaled)
      journal.changed_data = changes

      render

      response.should have_selector('journals', :count => 1) do |journal|

        journal.should have_selector('changes', :count => 1) do |changes|
          changes.each do |attr, (old, new)|
            changes.should have_selector('name', :text => attr)
            changes.should have_selector('old', :text => old)
            changes.should have_selector('new', :text => new)
          end
        end

      end
    end
  end
end

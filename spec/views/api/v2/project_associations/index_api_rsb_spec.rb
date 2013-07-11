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

describe 'api/v2/project_associations/index.api.rsb' do
  before do
    view.extend TimelinesHelper
  end

  before do
    params[:format] = 'xml'
  end

  describe 'with no project_associations available' do
    it 'renders an empty project_associations document' do
      assign(:project_associations, [])

      render

      response.should have_selector('project_associations', :count => 1)
      response.should have_selector('project_associations[type=array][size="0"]') do
        without_tag 'project_association'
      end
    end
  end

  describe 'with 3 project_associations available' do
    let(:project_associations) do
      [
        FactoryGirl.build(:project_association),
        FactoryGirl.build(:project_association),
        FactoryGirl.build(:project_association)
      ]
    end

    before do
      assign(:project_associations, project_associations)
    end

    it 'renders a project_associations document with the size 3 of array' do

      render

      response.should have_selector('project_associations', :count => 1)
      response.should have_selector('project_associations[type=array][size="3"]')
    end

    it 'renders a project_association for each assigned project_association' do

      render

      response.should have_selector('project_associations project_association', :count => 3)
    end

    it 'renders the _project_association template for each assigned project_association' do

      view.should_receive(:render).exactly(3).times.with(hash_including(:partial => '/api/v2/project_associations/project_association.api')).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/project_associations/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end

    it 'passes the project_associations as local var to the partial' do

      view.should_receive(:render).once.with(hash_including(:object => project_associations.first)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => project_associations.second)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => project_associations.third)).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"api/v2/project_associations/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end
  end
end

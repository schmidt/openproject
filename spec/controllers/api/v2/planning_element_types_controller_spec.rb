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

require File.expand_path('../../../../spec_helper', __FILE__)

describe Api::V2::PlanningElementTypesController do
  let (:current_user) { FactoryGirl.create(:admin) }

  before do
    User.stub(:current).and_return current_user
  end

  def enable_type(project, type)
    FactoryGirl.create(:enabled_planning_element_type,
                   :project_id => project.id,
                   :planning_element_type_id => type.id)
  end


  describe 'with project scope' do
    let(:project) { FactoryGirl.create(:project, :is_public => false) }

    describe 'index.xml' do
      def fetch
        get 'index', :project_id => project.identifier, :format => 'xml'
      end
      it_should_behave_like "a controller action which needs project permissions"

      describe 'with unknown project' do
        it 'raises ActiveRecord::RecordNotFound errors' do
          lambda do
            get 'index', :project_id => 'blah', :format => 'xml'
          end.should raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe 'with no planning element types available' do
        it 'assigns an empty planning_element_types array' do
          get 'index', :project_id => project.identifier, :format => 'xml'
          assigns(:planning_element_types).should == []
        end

        it 'renders the index builder template' do
          get 'index', :project_id => project.identifier, :format => 'xml'
          response.should render_template('planning_element_types/index', :formats => ["api"])
        end
      end

      describe 'with 3 planning element types available' do
        before do
          @created_planning_element_types = [
            FactoryGirl.create(:planning_element_type),
            FactoryGirl.create(:planning_element_type),
            FactoryGirl.create(:planning_element_type)
          ]

          @created_planning_element_types.each do |type|
            enable_type(project, type)
          end

          # Creating one PlanningElemenType which is not assigned to any
          # Project and should therefore not show up in projects with a project
          # type
          FactoryGirl.create(:planning_element_type)
        end

        it 'assigns an array with all planning element types' do
          get 'index', :project_id => project.identifier, :format => 'xml'
          assigns(:planning_element_types).should == @created_planning_element_types
        end

        it 'renders the index template' do
          get 'index', :project_id => project.identifier, :format => 'xml'
          response.should render_template('planning_element_types/index', :formats => ["api"])
        end
      end
    end

    describe 'show.xml' do
      def fetch
        @available_type = FactoryGirl.create(:planning_element_type, :id => '1337')
        enable_type(project, @available_type)

        get 'show', :project_id => project.identifier, :id => '1337', :format => 'xml'
      end
      it_should_behave_like "a controller action which needs project permissions"

      describe 'with unknown project' do
        it 'raises ActiveRecord::RecordNotFound errors' do
          lambda do
            get 'show', :project_id => 'blah', :id => '1337', :format => 'xml'
          end.should raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe 'with unknown planning element type' do
        it 'raises ActiveRecord::RecordNotFound errors' do
          lambda do
            get 'show', :project_id => project.identifier, :id => '1337', :format => 'xml'
          end.should raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe 'with an planning element type, which is not enabled in the project' do
        before do
          FactoryGirl.create(:planning_element_type, :id => '1337')
        end

        it 'raises ActiveRecord::RecordNotFound errors' do
          lambda do
            get 'show', :project_id => project.identifier, :id => '1337', :format => 'xml'
          end.should raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe 'with an available planning element type' do
        before do
          @available_planning_element_type = FactoryGirl.create(:planning_element_type,
                                                            :id => '1337')

          enable_type(project, @available_planning_element_type)
        end

        it 'assigns the available planning element type' do
          get 'show', :project_id => project.identifier, :id => '1337', :format => 'xml'
          assigns(:planning_element_type).should == @available_planning_element_type
        end

        it 'renders the show template' do
          get 'show', :project_id => project.identifier, :id => '1337', :format => 'xml'
          response.should render_template('planning_element_types/show', :formats => ["api"])
        end
      end
    end
  end

  describe 'without project scope' do
    describe 'index.xml' do
      def fetch
        get 'index', :format => 'xml'
      end
      it_should_behave_like "a controller action with unrestricted access"

      describe 'with no planning element types available' do
        it 'assigns an empty planning_element_types array' do
          get 'index', :format => 'xml'
          assigns(:planning_element_types).should == []
        end

        it 'renders the index builder template' do
          get 'index', :format => 'xml'
          response.should render_template('planning_element_types/index', :formats => ["api"])
        end
      end

      describe 'with 3 planning element types available' do
        before do
          @created_planning_element_types = [
            FactoryGirl.create(:planning_element_type),
            FactoryGirl.create(:planning_element_type),
            FactoryGirl.create(:planning_element_type)
          ]
        end

        it 'assigns an array with all planning element types' do
          get 'index', :format => 'xml'
          assigns(:planning_element_types).should == @created_planning_element_types
        end

        it 'renders the index template' do
          get 'index', :format => 'xml'
          response.should render_template('planning_element_types/index', :formats => ["api"])
        end
      end
    end

    describe 'show.xml' do
      describe 'with unknown planning element type' do
        if false # would like to write it this way
          it 'returns status code 404' do
            get 'show', :id => '1337', :format => 'xml'

            response.status.should == '404 Not Found'
          end

          it 'returns an empty body' do
            get 'show', :id => '1337', :format => 'xml'

            response.body.should be_empty
          end

        else # but have to write it that way
          it 'raises ActiveRecord::RecordNotFound errors' do
            lambda do
              get 'show', :id => '1337', :format => 'xml'
            end.should raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe 'with an available planning element type' do
        before do
          @available_planning_element_type = FactoryGirl.create(:planning_element_type, :id => '1337')
        end

        def fetch
          get 'show', :id => '1337', :format => 'xml'
        end
        it_should_behave_like "a controller action with unrestricted access"

        it 'assigns the available planning element type' do
          get 'show', :id => '1337', :format => 'xml'
          assigns(:planning_element_type).should == @available_planning_element_type
        end

        it 'renders the show template' do
          get 'show', :id => '1337', :format => 'xml'
          response.should render_template('planning_element_types/show', :formats => ["api"])
        end
      end
    end
  end
end

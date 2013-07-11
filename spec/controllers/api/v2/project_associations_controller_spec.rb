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

describe Api::V2::ProjectAssociationsController do
  let(:current_user) { FactoryGirl.create(:admin) }

  before do
    User.stub(:current).and_return current_user
  end

  describe 'index.xml' do
    describe 'w/o a given project' do
      it 'renders a 404 Not Found page' do
        get 'index', :format => 'xml'

        response.response_code.should == 404
      end
    end

    describe 'w/ an unknown project' do
      it 'renders a 404 Not Found page' do
        get 'index', :project_id => '4711', :format => 'xml'

        response.response_code.should == 404
      end
    end

    describe 'w/ a known project' do
      let(:project) { FactoryGirl.create(:project, :identifier => 'test_project') }

      def fetch
        get 'index', :project_id => project.id, :format => 'xml'
      end
      let(:permission) { :view_project_associations }

      it_should_behave_like "a controller action which needs project permissions"

      describe 'w/ the current user being a member' do
        describe 'w/o any project_associations within the project' do
          it 'assigns an empty project_associations array' do
            get 'index', :project_id => project.id, :format => 'xml'
            assigns(:project_associations).should == []
          end

          it 'renders the index builder template' do
            get 'index', :project_id => project.id, :format => 'xml'
            response.should render_template('project_associations/index', :formats => ["api"])
          end
        end

        describe 'w/ 3 project_associations within the project' do
          before do
            @created_project_associations = [
              FactoryGirl.create(:project_association, :project_a_id => project.id,
                                                             :project_b_id => FactoryGirl.create(:public_project).id),
              FactoryGirl.create(:project_association, :project_a_id => project.id,
                                                             :project_b_id => FactoryGirl.create(:public_project).id),
              FactoryGirl.create(:project_association, :project_b_id => project.id,
                                                             :project_a_id => FactoryGirl.create(:public_project).id)
            ]
          end

          it 'assigns a project_associations array containing all three elements' do
            get 'index', :project_id => project.id, :format => 'xml'
            assigns(:project_associations).should == @created_project_associations
          end

          it 'renders the index builder template' do
            get 'index', :project_id => project.id, :format => 'xml'
            response.should render_template('project_associations/index', :formats => ["api"])
          end
        end
      end
    end
  end

  describe 'show.xml' do
    describe 'w/o a valid project_association id' do
      describe 'w/o a given project' do
        it 'renders a 404 Not Found page' do
          get 'show', :id => '4711', :format => 'xml'

          response.response_code.should == 404
        end
      end

      describe 'w/ an unknown project' do
        it 'renders a 404 Not Found page' do
          get 'index', :project_id => '4711', :id => '1337', :format => 'xml'

          response.response_code.should == 404
        end
      end

      describe 'w/ a known project' do
        let(:project) { FactoryGirl.create(:project, :identifier => 'test_project') }

        describe 'w/ the current user being a member' do
          it 'raises ActiveRecord::RecordNotFound errors' do
            lambda do
              get 'show', :project_id => project.id, :id => '1337', :format => 'xml'
            end.should raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end

    describe 'w/ a valid project_association id' do
      let(:project) { FactoryGirl.create(:project, :identifier => 'test_project') }
      let(:project_association) { FactoryGirl.create(:project_association, :project_a_id => project.id) }

      describe 'w/o a given project' do
        it 'renders a 404 Not Found page' do
          get 'show', :id => project_association.id, :format => 'xml'

          response.response_code.should == 404
        end
      end

      describe 'w/ a known project' do
        def fetch
          get 'show', :project_id => project.id, :id => project_association.id, :format => 'xml'
        end
        let(:permission) { :view_project_associations }

        it_should_behave_like "a controller action which needs project permissions"

        describe 'w/ the current user being a member' do
          it 'assigns the project_association' do
            get 'show', :project_id => project.id, :id => project_association.id, :format => 'xml'
            assigns(:project_association).should == project_association
          end

          it 'renders the index builder template' do
            get 'index', :project_id => project.id, :id => project_association.id, :format => 'xml'
            response.should render_template('project_associations/index', :formats => ["api"])
          end
        end
      end
    end
  end
end

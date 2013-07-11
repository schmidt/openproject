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

module PermissionSpecHelpers
  def spec_permissions(test_denied = true)
    describe 'w/ valid auth' do
      before { User.stub(:current).and_return valid_user }

      it 'grants access' do
        fetch

        if respond_to? :expect_redirect_to
          response.should be_redirect

          case expect_redirect_to
          when true
            response.redirect_url.should_not =~ %r'/login'
          when Regexp
            response.redirect_url.should =~ expect_redirect_to
          else
            response.should redirect_to(expect_redirect_to)
          end
        elsif respond_to? :expect_no_content
          response.response_code.should == 204
        else
          response.response_code.should == 200
        end
      end
    end

    describe 'w/o valid auth' do
      before { User.stub(:current).and_return invalid_user }

      it 'denies access' do
        fetch

        if invalid_user.logged?
          response.response_code.should == 403
        else
          if controller.send(:api_request?)
            response.response_code.should == 401
          else
            response.should be_redirect
            response.redirect_url.should =~ %r'/login'
          end
        end
      end
    end if test_denied
  end
end

shared_examples_for "a controller action with unrestricted access" do
  let(:valid_user) { FactoryGirl.create(:anonymous) }

  extend PermissionSpecHelpers
  spec_permissions(false)
end

shared_examples_for "a controller action with require_login" do
  let(:valid_user)   { FactoryGirl.create(:user) }
  let(:invalid_user) { FactoryGirl.create(:anonymous) }

  extend PermissionSpecHelpers
  spec_permissions
end

shared_examples_for "a controller action with require_admin" do
  let(:valid_user)   { User.first(:conditions => {:admin => true}) || FactoryGirl.create(:admin) }
  let(:invalid_user) { FactoryGirl.create(:user) }

  extend PermissionSpecHelpers
  spec_permissions
end

shared_examples_for "a controller action which needs project permissions" do
  # Expecting the following environment
  #
  # let(:project) { FactoryGirl.create(:project) }
  #
  # def fetch
  #   get 'action', :project_id => project.identifier
  # end
  #
  # Optionally also provide the following
  #
  # let(:permission) { :edit_project }
  #
  # def expect_redirect_to
  #   # Regexp - which should match the full redirect URL
  #   # true   - action should redirect, but not to /login
  #   # other  - passed to response.should redirect_to(other)
  #   true
  # end
  let(:valid_user) { FactoryGirl.create(:user) }
  let(:invalid_user) { FactoryGirl.create(:user) }

  def add_membership(user, permissions)
    role   = FactoryGirl.create(:role, :permissions => Array(permissions))
    member = FactoryGirl.build(:member, :user => user, :project => project)
    member.roles = [role]
    member.save!
  end

  before do
    if defined? permission
      # special permission needed - make valid_user a member with proper role,
      # invalid_user is member without special rights
      add_membership(valid_user, permission)
      add_membership(invalid_user, :view_project)
    else
      # no special permission needed - make valid_user a simple member,
      # invalid_user is non-member
      add_membership(valid_user, :view_project)
    end
  end

  extend PermissionSpecHelpers
  spec_permissions
end

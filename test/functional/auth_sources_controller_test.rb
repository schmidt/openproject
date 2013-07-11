#-- encoding: UTF-8
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

require File.expand_path('../../test_helper', __FILE__)

class AuthSourcesControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    super
    @request.session[:user_id] = 1
  end

  context "get :index" do
    setup do
      get :index
    end

    should_assign_to :auth_sources
    should respond_with :success
    should render_template :index
  end

  context "get :new" do
    setup do
      get :new
    end

    should_assign_to :auth_source
    should respond_with :success
    should render_template :new

    should "initilize a new AuthSource" do
      assert_equal AuthSource, assigns(:auth_source).class
      assert assigns(:auth_source).new_record?
    end
  end

  context "post :create" do
    setup do
      post :create, :auth_source => {:name => 'Test'}
    end

    should respond_with :redirect
    should redirect_to("index") {{:action => 'index'}}
    should set_the_flash.to /success/i
  end

  context "get :edit" do
    setup do
      @auth_source = AuthSource.generate!(:name => 'TestEdit')
      get :edit, :id => @auth_source.id
    end

    should_assign_to(:auth_source) {@auth_source}
    should respond_with :success
    should render_template :edit
  end

  context "post :update" do
    setup do
      @auth_source = AuthSource.generate!(:name => 'TestEdit')
      post :update, :id => @auth_source.id, :auth_source => {:name => 'TestUpdate'}
    end

    should respond_with :redirect
    should redirect_to("index") {{:action => 'index'}}
    should set_the_flash.to /update/i
  end

  context "post :destroy" do
    setup do
      @auth_source = AuthSource.generate!(:name => 'TestEdit')
    end

    context "without users" do
      setup do
        post :destroy, :id => @auth_source.id
      end

      should respond_with :redirect
      should redirect_to("index") {{:action => 'index'}}
      should set_the_flash.to /deletion/i
    end

    context "with users" do
      setup do
        User.generate!(:auth_source => @auth_source)
        post :destroy, :id => @auth_source.id
      end

      should respond_with :redirect
      should "not destroy the AuthSource" do
        assert AuthSource.find(@auth_source.id)
      end
    end
  end
end

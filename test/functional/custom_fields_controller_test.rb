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
require 'custom_fields_controller'

# Re-raise errors caught by the controller.
class CustomFieldsController; def rescue_action(e) raise e end; end

class CustomFieldsControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    super
    @controller = CustomFieldsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1
  end

  def test_get_new_issue_custom_field
    get :new, :type => 'WorkPackageCustomField'
    assert_response :success
    assert_template 'new'
    assert_tag :select,
      :attributes => {:name => 'custom_field[field_format]'},
      :child => {
        :tag => 'option',
        :attributes => {:value => 'user'},
        :content => 'User'
      }
    assert_tag :select,
      :attributes => {:name => 'custom_field[field_format]'},
      :child => {
        :tag => 'option',
        :attributes => {:value => 'version'},
        :content => 'Version'
      }
  end

  def test_get_new_with_invalid_custom_field_class_should_redirect_to_list
    get :new, :type => 'UnknownCustomField'
    assert_redirected_to '/custom_fields'
  end

  def test_post_new_list_custom_field
    assert_difference 'CustomField.count' do
      post :new, :type => "WorkPackageCustomField",
                 :custom_field => {:name => "test_post_new_list",
                                   :default_value => "",
                                   :min_length => "0",
                                   :searchable => "0",
                                   :regexp => "",
                                   :is_for_all => "1",
                                   :possible_values => "0.1\n0.2\n",
                                   :max_length => "0",
                                   :is_filter => "0",
                                   :is_required =>"0",
                                   :field_format => "list",
                                   :type_ids => ["1", ""]}
    end
    assert_redirected_to '/custom_fields?tab=WorkPackageCustomField'
    field = WorkPackageCustomField.find_by_name('test_post_new_list')
    assert_not_nil field
    assert_equal ["0.1", "0.2"], field.possible_values
    assert_equal 1, field.types.size
  end
end

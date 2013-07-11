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

class ApplicationTest < ActionDispatch::IntegrationTest
  include Redmine::I18n

  fixtures :all

  def test_set_localization
    Setting.available_languages = [:de, :en]
    Setting.default_language = 'en'

    # a french user
    get 'projects', { }, { 'HTTP_ACCEPT_LANGUAGE' => 'de,de-de;q=0.8,en-us;q=0.5,en;q=0.3'}
    assert_response :success
    assert_tag :tag => 'h2', :content => 'Projekte'
    assert_equal :de, current_language

    # not a supported language: default language should be used
    get 'projects', { }, 'HTTP_ACCEPT_LANGUAGE' => 'zz'
    assert_response :success
    assert_tag :tag => 'h2', :content => 'Projects'
  end

  def test_token_based_access_should_not_start_session
    # issue of a private project
    get 'issues/4.atom'
    assert_response 302

    rss_key = User.find(2).rss_key
    get "issues/4.atom?key=#{rss_key}"
    assert_response 200
    assert_nil session[:user_id]
  end
end

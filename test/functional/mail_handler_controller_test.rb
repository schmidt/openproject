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
require 'mail_handler_controller'

# Re-raise errors caught by the controller.
class MailHandlerController; def rescue_action(e) raise e end; end

class MailHandlerControllerTest < ActionController::TestCase
  fixtures :all

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/mail_handler'

  def setup
    super
    @controller = MailHandlerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_should_create_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_project.eml'))
    assert_response 201
  end

  def test_should_not_allow
    # Disable API
    Setting.mail_handler_api_enabled = 0
    Setting.mail_handler_api_key = 'secret'

    post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_project.eml'))
    assert_response 403
  end
end

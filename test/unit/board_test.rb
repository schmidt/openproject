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

class BoardTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    super
    @project = Project.find(1)
  end

  def test_create
    board = Board.new(:project => @project, :name => 'Test board', :description => 'Test board description')
    assert board.save
    board.reload
    assert_equal 'Test board', board.name
    assert_equal 'Test board description', board.description
    assert_equal @project, board.project
    assert_equal 0, board.topics_count
    assert_equal 0, board.messages_count
    assert_nil board.last_message
    # last position
    assert_equal @project.boards.size, board.position
  end

  def test_destroy
    board = Board.find(1)
    assert_difference 'Message.count', -6 do
      assert_difference 'Attachment.count', -1 do
        assert_difference 'Watcher.count', -1 do
          assert board.destroy
        end
      end
    end
    assert_equal 0, Message.count(:conditions => {:board_id => 1})
  end
end

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

Feature: Watch issues
  Background:
    Given there are no issues
    And there is 1 project with the following:
      | name        | parent      |
      | identifier  | parent      |
    And I am working in project "parent"
    And the project "parent" has the following trackers:
      | name | position |
      | Bug  |     1    |
    And there is a default issuepriority with:
      | name   | Normal |
    And there is a role "member"
    And the role "member" may have the following rights:
      | view_work_packages |
    And there is 1 user with the following:
      | login     | bob    |
      | firstname | Bob    |
      | lastname  | Bobbit |
      | admin     | true   |
    And the user "bob" is a "member" in the project "parent"
    Given the user "bob" has 1 issue with the following:
      | subject     | issue1              |
    And I am logged in as "bob"

  @javascript
  Scenario: Watch an issue
    When I go to the page of the issue "issue1"
    Then I should see "Watch" within "#content > .action_menu_main"
    When I click on "Watch" within "#content > .action_menu_main"
    Then I should see "Unwatch" within "#content > .action_menu_main"
    Then the issue "issue1" should have 1 watchers

  @javascript
  Scenario: Unwatch an issue
    Given the issue "issue1" is watched by:
      | bob |
    When I go to the page of the issue "issue1"
    Then I should see "Unwatch" within "#content > .action_menu_main"
    When I click on "Unwatch" within "#content > .action_menu_main"
    Then I should see "Watch" within "#content > .action_menu_main"
    Then the issue "issue1" should have 0 watchers

  @javascript
  Scenario: Add a watcher to an issue
    When I go to the page of the issue "issue1"
    Then I should see "Add watcher" within "#content > .issue > #watchers"
    When I click on "Add watcher" within "#content > .issue > #watchers"
    And I select "Bob Bobbit" from "watcher_user_id" within "#content > .issue > #watchers"
    And I press "Add" within "#content > .issue > #watchers"
    Then I should see "Bob Bobbit" within "#content > .issue > #watchers > ul"
    Then the issue "issue1" should have 1 watchers

  @javascript
  Scenario: Remove a watcher from an issue
    Given the issue "issue1" is watched by:
      | bob |
    When I go to the page of the issue "issue1"
    Then I should see "Bob Bobbit" within "#content > .issue > #watchers > ul"
    When I click on "Delete" within "#content > .issue > #watchers > ul"
    Then I should not see "Bob Bobbit" within "#content > .issue > #watchers"
    Then the issue "issue1" should have 0 watchers

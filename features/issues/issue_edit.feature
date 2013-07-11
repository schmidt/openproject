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

Feature: Issue edit
  Background:
    Given there is 1 project with the following:
      | identifier | omicronpersei8 |
      | name       | omicronpersei8 |
    And I am working in project "omicronpersei8"
    And the project "omicronpersei8" has the following trackers:
      | name | position |
      | Bug  |     1    |
    And there is a default issuepriority with:
      | name   | Normal |
    And there is a role "member"
    And the role "member" may have the following rights:
      | add_issues  |
      | view_work_packages |
      | edit_work_packages |
      | manage_subtasks |
    And there is 1 user with the following:
      | login | bob|
    And the user "bob" is a "member" in the project "omicronpersei8"
    And there are the following issue status:
      | name        | is_closed  | is_default  |
      | New         | false      | true        |
    Given the user "bob" has 1 issue with the following:
      |  subject      | issue1             |
      |  description  | Aioli Sali Grande  |
    And I am logged in as "bob"

  @javascript
  Scenario: User updates an issue successfully
    When I go to the page of the issue "issue1"
    Then I should see "Update" within "#content > .action_menu_main"
    And I should not see "Change properties"
    When I click on "Update" within "#content > .action_menu_main"
    Then I should see "Change properties"
    Then I fill in "notes" with "human Horn"
    And I click on "Submit"
    And I should see "Successful update." within ".notice"
    And I should see "human Horn" within "#history"

  @javascript
  Scenario: User updates an issue with previewing the stuff before
    When I go to the page of the issue "issue1"
    Then I should see "Update" within "#content > .action_menu_main"
    And I should not see "Change properties"
    When I click on "Update" within "#content > .action_menu_main"
    Then I should see "Change properties"
    Then I fill in "notes" with "human Horn"
    When I click on "Preview" within "#issue-form"
    Then I should see "human Horn" within "#preview"
    Then I click on "Submit"
    And I should see "Successful update." within ".notice"
    And I should see "human Horn" within "#history"

  @javascript
  Scenario: On an issue with children a User should not be able to change attributes which are overridden by children
    When I go to the page of the issue "issue1"
    And I click on "Add subtask"
    Then I should see "New issue" within "#content"
    When I fill in "find the popplers" for "Subject"
    And I click on the first button matching "Create"
    Then I should see "Successful creation."
    When I go to the page of the issue "issue1"
    And I click on "Update" within "#content > .action_menu_main"
    Then I should see "Change properties"
    And I should not see "% Done" within "#issue-form"
    And there should be the disabled "#issue_priority_id" element within "#issue-form"
    And there should be the disabled "#issue_start_date" element within "#issue-form"
    And there should be the disabled "#issue_due_date" element within "#issue-form"
    And there should be the disabled "#issue_estimated_hours" element within "#issue-form"

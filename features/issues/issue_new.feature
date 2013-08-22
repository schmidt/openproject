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
    And the project "omicronpersei8" has the following types:
      | name | position |
      | Bug  |     1    |
    And there is a default issuepriority with:
      | name   | Normal |
    And there is a issuepriority with:
      | name   | High |
    And there is a issuepriority with:
      | name   | Immediate |
    And there is a role "member"
    And the role "member" may have the following rights:
      | add_issues         |
      | add_work_packages  |
      | view_work_packages |
      | edit_work_packages |
    And there is 1 user with the following:
      | login | lrrr|
    And the user "lrrr" is a "member" in the project "omicronpersei8"
    And there are the following issue status:
      | name        | is_closed  | is_default  |
      | New         | false      | true        |
    And I am logged in as "lrrr"

  Scenario: While creating an issue the user can change attributes which are overriden by children
    When I go to the new work_package page of the project called "omicronpersei8"
    And I fill in "find the popplers" for "Subject"
    And I select "High" from "Priority"
    And I fill in "2013-06-18" for "Start date"
    And I fill in "2013-07-18" for "Due date"
    And I fill in "7" for "Estimated time"
    And I select "50 %" from "% done"
    And I submit the form by the "Create" button
    Then I should see "Successful creation."


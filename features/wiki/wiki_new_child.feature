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

Feature: Viewing the wiki new child page

  Background:
    Given there are no wiki menu items
    And there is 1 user with the following:
      | login | bob |
    And there is a role "member"
    And the role "member" may have the following rights:
      | view_wiki_pages   |
      | edit_wiki_pages   |
    And there is 1 project with the following:
      | name       | project1 |
      | identifier | project1 |
    And the user "bob" is a "member" in the project "project1"
    And I am logged in as "bob"

  Scenario: Visiting the wiki new child page with a parent page that has the new child page option enabled on it's menu item should show the page and select the toc menu entry within the wiki menu item
    Given the project "project1" has 1 wiki page with the following:
      | title | ParentWikiPage |
    And the project "project1" has 1 wiki menu item with the following:
      | title         | ParentWikiPage |
      | new_wiki_page | true           |
    When I go to the wiki new child page below the "ParentWikiPage" page of the project called "project1"
    Then I should see "Create new child page" within "#content"
    And the child page wiki menu item inside the "ParentWikiPage" menu item should be selected

  Scenario: Visiting the wiki new child page with a related page that has the new child page option disabled on it's menu item should show the page and select no menu item
    Given the project "project1" has 1 wiki page with the following:
      | title | ParentWikiPage |
    And the project "project1" has 1 wiki menu item with the following:
      | title      | ParentWikiPage |
    When I go to the wiki new child page below the "ParentWikiPage" page of the project called "project1"
    Then I should see "Create new child page" within "#content"
    And there should be no menu item selected

  Scenario: Visiting the wiki new child page with an invalid parent page
    When I go to the wiki new child page below the "InvalidPage" page of the project called "project1"
    Then I should see "404" within "#content"
    Then I should see "The page you were trying to access doesn't exist or has been removed."

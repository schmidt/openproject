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

Feature: Wiki menu items
  Background:
    Given there is 1 project with the following:
      | name        | Awesome Project      |
      | identifier  | awesome-project      |
    And there is a role "member"
    And the role "member" may have the following rights:
      | view_wiki_pages  |
      | edit_wiki_pages  |
      | manage_wiki_menu |
    And there is 1 user with the following:
      | login | bob |
    And the user "bob" is a "member" in the project "Awesome Project"
    And the project "Awesome Project" has 1 wiki page with the following:
      | Title | Wiki |
    And the project "Awesome Project" has 1 wiki page with the following:
      | Title | AwesomePage |
    And I am logged in as "bob"

    @javascript
  Scenario: Adding a main menu entry without index and toc links
    When I go to the wiki page "AwesomePage" for the project called "Awesome Project"
    And I click on "More functions"
    And I click on "Configure menu item"
    And I fill in "Avocado Wuaärst" for "wiki_menu_item_name"
    And I choose "Show as menu item in project navigation"
    And I press "Save"
    And I should see "Avocado Wuaärst" within "#main-menu"

    @javascript
  Scenario: Adding a main menu entry with index and toc links
    When I go to the wiki page "AwesomePage" for the project called "Awesome Project"
    And I click on "More functions"
    And I click on "Configure menu item"
    And I fill in "Avocado Wuaärst" for "wiki_menu_item_name"
    And I choose "Show as menu item in project navigation"
    And I check "Show submenu item 'Create new child page'"
    And I check "Show submenu item 'Table of Contents'"
    And I press "Save"
    When I go to the wiki page "AwesomePage" for the project called "Awesome Project"
    Then I should see "Avocado Wuaärst" within "#main-menu"
    Then I should see "Table of Contents" within "#main-menu"
    Then I should see "Create new child page" within "#main-menu"

    @javascript
  Scenario: Change existing entry
    When I go to the wiki page "Wiki" for the project called "Awesome Project"
    Then I should see "Table of Contents" within "#main-menu"
    Then I should see "Create new child page" within "#main-menu"
    When I click on "More functions"
    And I click on "Configure menu item"
    And I fill in "Wikikiki" for "wiki_menu_item_name"
    And I uncheck "Show submenu item 'Table of Contents'"
    And I uncheck "Show submenu item 'Create new child page'"
    And I press "Save"
    When I go to the wiki page "Wiki" for the project called "Awesome Project"
    Then I should see "Wikikiki" within "#main-menu"
    Then I should not see "Table of Contents" within "#main-menu"
    Then I should not see "Create new child page" within "#main-menu"


    @javascript
  Scenario: Adding a sub menu entry
    Given the project "Awesome Project" has a wiki menu item with the following:
      | title | SelectMe |
      | name | SelectMe   |
    Given the project "Awesome Project" has a wiki menu item with the following:
      | title | AwesomePage |
      | name | RichtigGeil |
    When I go to the wiki page "Wiki" for the project called "Awesome Project"
    When I click on "More functions"
    And I click on "Configure menu item"
    And I choose "Show as submenu item of"
    When I select "SelectMe" from "parent_wiki_menu_item"
    When I select "RichtigGeil" from "parent_wiki_menu_item"
    And I press "Save"
    When I go to the wiki page "Wiki" for the project called "Awesome Project"
    Then I should see "Wiki" within ".menu-children"

    @javascript
  Scenario: Removing a menu item
    Given the project "Awesome Project" has a wiki menu item with the following:
      | title | DontKillMe |
      | name | DontKillMe  |
    When I go to the wiki page "Wiki" for the project called "Awesome Project"
    When I click on "More functions"
    And I click on "Configure menu item"
    And I choose "Do not show this wikipage in project navigation"
    And I press "Save"
    Then I should not see "Wiki" within "#main-menu"

Feature: Membership

  Background:
    Given I am admin

    Given there is a role "Manager"
      And there is a role "Developer"

      And there is 1 project with the following:
        | Name       | Project1 |
        | Identifier | project1 |

      And there is 1 User with:
        | Login     | peter |
        | Firstname | Peter |
        | Lastname  | Pan   |

      And there is 1 User with:
        | Login     | hannibal |
        | Firstname | Hannibal |
        | Lastname  | Smith    |

      And there is a group named "A-Team" with the following members:
        | peter    |
        | hannibal |


  @javascript
  Scenario: Adding and Removing a Group as Member, non impaired
     When I go to the settings page of the project called "Project1"
      And I click on "tab-members"
      And I add the principal "A-Team" as "Manager"
     Then I should be on the settings page of the project called "Project1"
      And I should see "Successful creation." within ".flash.notice"
      And I should see "A-Team" within ".members"

     When I delete the "A-Team" membership
      And I wait for the AJAX requests to finish
     Then I should see "No data to display"

  @javascript
  Scenario: Adding and removing a User as Member, non impaired
     When I go to the settings page of the project called "Project1"
      And I click on "tab-members"
      And I add the principal "Hannibal Smith" as "Manager"
     Then I should see "Successful creation." within ".flash.notice"
      And I should see "Hannibal Smith" within ".members"

     When I delete the "Hannibal Smith" membership
      And I wait for the AJAX requests to finish
     Then I should see "No data to display"

  @javascript
  Scenario: Adding and Removing a Group as Member, impaired
     When I am impaired
      And I go to the settings page of the project called "Project1"
      And I click on "tab-members"
      And I add the principal "A-Team" as "Manager"
     Then I should be on the settings page of the project called "Project1"
      And I should see "Successful creation." within ".flash.notice"
      And I should see "A-Team" within ".members"

     When I delete the "A-Team" membership
      And I wait for the AJAX requests to finish
     Then I should see "No data to display"

  @javascript
  Scenario: Adding and removing a User as Member, impaired
     When I am impaired
      And I go to the settings page of the project called "Project1"
      And I click on "tab-members"
      And I add the principal "Hannibal Smith" as "Manager"
     Then I should see "Successful creation." within ".flash.notice"
      And I should see "Hannibal Smith" within ".members"

     When I delete the "Hannibal Smith" membership
      And I wait for the AJAX requests to finish
     Then I should see "No data to display"


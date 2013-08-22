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

Feature: Fields editable on work package edit
  Background:
    Given there is 1 user with:
      | login     | manager |
      | firstname | the     |
      | lastname  | manager |
    And there is a role "manager"
    And there is 1 project with the following:
      | identifier | ecookbook |
      | name       | ecookbook |
    And I am working in project "ecookbook"
    And the user "manager" is a "manager"
    And I am already logged in as "manager"

  @javascript
  Scenario: Going to the page and viewing all the fields
    Given there are the following types:
      | Name      | Is Milestone | In aggregation |
      | Phase     | false        | true           |
    And there are the following project types:
      | Name                  |
      | Standard Project      |
    And the project named "ecookbook" is of the type "Standard Project"
    And there is an issuepriority with:
      | name | prio1 |
    And the role "manager" may have the following rights:
      | edit_work_packages |
      | view_work_packages |
      | manage_subtasks    |
    And the project "ecookbook" has 1 version with:
      | name | version1 |
    And the following types are enabled for projects of type "Standard Project"
      | Phase |
    And there are the following planning elements in project "ecookbook":
      | subject  | description     | start_date | due_date   | done_ratio | type  | responsible | assigned_to | priority | parent   | estimated_hours | fixed_version |
      | parentpe |                 |            |            | 0          | Phase |             |             | prio1    |          |                 |               |
      | pe1      | pe1 description | 2013-01-01 | 2013-12-31 | 30         | Phase | manager     | manager     | prio1    | parentpe | 5               | version1      |

    When I go to the edit page of the work package called "pe1"
    And I follow "More"

    Then I should see the following fields:
      | Type            | Phase1           |
      | Subject         | pe1              |
      | Description     | pe1 description  |
      | Priority        | prio1            |
      | Assignee        | the manager      |
      | Responsible     | the manager      |
      | Target version  | version1         |
      | Start date      | 2013-01-01       |
      | Due date        | 2013-12-31       |
      | Estimated time  | 5.00             |
      | % done          | 30 %             |
      | Notes           |                  |
    And the "Parent" field should contain the id of work package "parentpe"


  Scenario: Going to the page and viewing timelog fields if this module is enabled
    Given the role "manager" may have the following rights:
      | edit_work_packages |
      | view_work_packages |
      | log_time           |

    And there are the following planning elements in project "ecookbook":
      | subject |
      | pe1     |

    And the project "ecookbook" uses the following modules:
      | time_tracking |

    And there is an activity "design"

    When I go to the edit page of the work package called "pe1"

    Then I should see the following fields:
      | Spent time |
      | Activity   |
      | Comment    |

  Scenario: Going to the page and viewing custom field fields
    Given the role "manager" may have the following rights:
      | edit_work_packages |

    Given the following work package custom fields are defined:
      | name | type  |
      | cf1  | int   |

    And there are the following planning elements in project "ecookbook":
      | subject |
      | pe1     |

    And the work package "pe1" has the custom field "cf1" set to "4"

    When I go to the edit page of the work package called "pe1"

    Then I should see the following fields:
      | cf1 | 4 |

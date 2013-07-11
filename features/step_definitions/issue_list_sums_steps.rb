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

# TODO: check if this step can be removed as it is plugin specific
Given /^there is a standard project named "([^\"]*)"$/ do |name|
  steps %Q{
    Given there is 1 project with the following:
      | Name | #{name} |
    And there is a role "Manager"
    And there is a role "Developer"
    And there is a role "Designer"
    And the role "Manager" may have the following rights:
      | view_own_hourly_rate     |
      | view_hourly_rates        |
      | view_cost_rates          |
      | view_own_time_entries    |
      | view_own_cost_entries    |
      | view_cost_entries        |
      | view_time_entries        |
    And the role "Developer" may have the following rights:
      | view_own_hourly_rate     |
      | view_hourly_rates        |
      | view_cost_rates          |
      | view_own_time_entries    |
      | view_own_cost_entries    |
      | view_cost_entries        |
      | view_time_entries        |
    And the role "Designer" may have the following rights:
      | view_own_hourly_rate     |
      | view_hourly_rates        |
      | view_cost_rates          |
      | view_own_time_entries    |
      | view_own_cost_entries    |
      | view_cost_entries        |
      | view_time_entries        |
    And there is 1 user with:
      | Login        | manager   |
      | Firstname    | Mac       |
      | Lastname     | Moneysack |
      | default rate | 10.00     |
    And there is 1 user with:
      | Login        | developer |
      | Firstname    | Alan      |
      | Lastname     | Kay       |
      | default rate | 10.00     |
    And there is 1 user with:
      | Login        | designer |
      | Firstname    | Tom      |
      | Lastname     | Kelley   |
      | default rate | 10.00    |
    And the user "manager" is a "Manager" in the project "#{name}"
    And the user "designer" is a "Designer" in the project "#{name}"
    And the user "developer" is a "Developer" in the project "#{name}"
  }
end

Then /^[iI] should (not )?see "([^\"]*)" in the overall sum(?:s)?$/ do |negative, sum|
  step %Q{I should #{negative}see "#{sum}" within "tr.sum.all"}
end

Then /^[iI] should see "([^\"]*)" in the grouped sum(?:s)?$/ do |sum|
  find(:xpath, "//tr[contains(concat(' ',normalize-space(@class),' '),' grouped ')]/td[contains(text(), '#{sum}')]").should_not(be_nil, "Could not find the grouped sum '#{sum}'")
end

Then /^[iI] should not see "([^\"]*)" in the grouped sum(?:s)?$/ do |sum|
  begin
    find(:xpath, "//tr[contains(concat(' ',normalize-space(@class),' '),' grouped ')]/td[contains(text(), '#{sum}')]").should(be_nil, "Could find the grouped sum '#{sum}'")
  rescue Capybara::ElementNotFound => e
    # it's fine when the element is not there at all
  end
end

Then /^[iI] toggle the [oO]ptions fieldset$/ do
  page.execute_script <<-JS
    f = $$("fieldset").without($("filters")).first();
    toggleFieldset($(f).select("legend").first());
  JS
end

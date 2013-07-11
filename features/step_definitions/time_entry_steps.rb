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

Given(/^there is a time entry for "(.*?)" with (\d+) hours$/) do |subject, hours|
  work_package = WorkPackage.find_by_subject(subject)
  time_entry = FactoryGirl.create(:time_entry, work_package: work_package, hours: hours, project: work_package.project)
end

Given(/^there is an activity "(.*?)"$/) do |name|
  FactoryGirl.create(:time_entry_activity, name: name)
end

When(/^I log (\d+) hours with the comment "(.*?)"$/) do |hours, comment|
  click_link I18n.t(:button_log_time)
  fill_in TimeEntry.human_attribute_name(:hours), with: hours
  fill_in TimeEntry.human_attribute_name(:comment), with: comment
  select "Development", from: "Activity"
  click_button I18n.t(:button_save)
end

Then(/^I should see a time entry with (\d+) hours and comment "(.*)"$/) do |hours, comment|
  expect(page).to have_content("#{hours}.00")
  expect(page).to have_content(comment)
end

Then(/^I should see a total spent time of (\d+) hours$/) do |hours|
  within('div.total-hours') do
    expect(find("span.hours-int")).to have_content hours
  end
end

When(/^I update the first time entry with (\d+) hours and the comment "(.*?)"$/) do |hours, comment|
  click_link I18n.t("button_edit")
  fill_in TimeEntry.human_attribute_name(:hours), with: hours
  fill_in TimeEntry.human_attribute_name(:comment), with: comment
  click_button "Save"
end


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

When /^I toggle the "([^"]+)" submenu$/ do |menu_name|
  nodes = all(:css, ".menu_root a[title=\"#{menu_name}\"] .toggler")

  # w/o javascript, all menu elements are expanded by default. So the toggler
  # might not be present.
  nodes.first.click if nodes.present?
end

Then /^there should be no menu item selected$/ do
  page.should_not have_css("#main-menu .selected")
end

When /^I select "(.+?)" from the action menu$/ do |entry_name|
  within(action_menu_selector) do
    if !find_link(entry_name).visible?
      click_link(I18n.t(:more_actions))
    end

    click_link(entry_name, :visible => false)
  end
end

Then /^there should not be a "(.+?)" entry in the action menu$/ do |entry_name|
  within(action_menu_selector) do
    should_not have_link(entry_name)
  end
end

def action_menu_selector
  # supports both the old and the new selector for the action menu
  # please note that using this with the old .contextual selector takes longer
  # as capybara waits for the new .action_menu_main selector to appear

  if has_css?(".action_menu_main", :visible => true)
    all(".action_menu_main", :visible => true).first
  elsif has_css?(".contextual", :visible => true)
    all(".contextual", :visible => true).first
  else
    raise "No action menu on the current page"
  end
end

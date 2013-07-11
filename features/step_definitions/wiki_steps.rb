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

Given /^there are no wiki menu items$/ do
  WikiMenuItem.destroy_all
end

Given /^the project "(.*?)" has (?:1|a) wiki menu item with the following:$/ do |project_name, table|
  item = FactoryGirl.build(:wiki_menu_item)
  send_table_to_object(item, table)
  item.wiki = Project.find_by_name(project_name).wiki
  item.save!
end

Given /^the project "(.*?)" has a child wiki page of "(.*?)" with the following:$/ do |project_name, parent_page_title, table|
  wiki = Project.find_by_name(project_name).wiki
  wikipage = FactoryGirl.build(:wiki_page, :wiki => wiki)

  send_table_to_object(wikipage, table)

  FactoryGirl.create(:wiki_content, :page => wikipage)

  parent_page = WikiPage.find_by_wiki_id_and_title(wiki.id, parent_page_title)
  wikipage.parent_id = parent_page.id
  wikipage.save!
end

Then /^the table of contents wiki menu item inside the "(.*?)" menu item should be selected$/ do |parent_item_name|
  parent_item = WikiMenuItem.find_by_title(parent_item_name)

  page.should have_css(".#{parent_item.item_class}-toc.selected")
end

Then /^the child page wiki menu item inside the "(.*?)" menu item should be selected$/ do |parent_item_name|
  parent_item = WikiMenuItem.find_by_title(parent_item_name)

  page.should have_css(".#{parent_item.item_class}-new-page.selected")
end


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

[CustomField, WorkPackageCustomField].each do |const|
  InstanceFinder.register(const, Proc.new{ |name| const.find_by_name(name) })
  RouteMap.register(const, "/custom_fields")
end

Given /^the following (user|issue|work package) custom fields are defined:$/ do |type, table|
  type = (type.gsub(" ", "_") + "_custom_field").to_sym

  as_admin do
    table.hashes.each_with_index do |r, i|
      attr_hash = { :name => r['name'],
                    :field_format => r['type']}

      attr_hash[:possible_values] = r['possible_values'].split(",").collect(&:strip) if r['possible_values']
      attr_hash[:is_required] = (r[:required] == 'true') if r[:required]
      attr_hash[:editable] = (r[:editable] == 'true') if r[:editable]
      attr_hash[:visible] = (r[:visible] == 'true') if r[:visible]
      attr_hash[:is_filter] = (r[:is_filter] == 'true') if r[:is_filter]
      attr_hash[:default_value] = r[:default_value] ? r[:default_value] : nil
      attr_hash[:is_for_all] = r[:is_for_all] || true

      FactoryGirl.create type, attr_hash
    end
  end
end

Given /^the user "(.+?)" has the user custom field "(.+?)" set to "(.+?)"$/ do |login, field_name, value|
  user = User.find_by_login(login)
  custom_field = UserCustomField.find_by_name(field_name)

  user.custom_values.build(:custom_field => custom_field, :value => value)
  user.save!
end

Given /^the work package "(.+?)" has the custom field "(.+?)" set to "(.+?)"$/ do |wp_name, field_name, value|
  wp = InstanceFinder.find(WorkPackage, wp_name)
  custom_field = InstanceFinder.find(WorkPackageCustomField, field_name)

  wp.custom_values.build(:custom_field => custom_field, :value => value)
  wp.save!
end

Given /^the custom field "(.+)" is( not)? summable$/ do |field_name, negative|
  custom_field = WorkPackageCustomField.find_by_name(field_name)

  Setting.issue_list_summable_columns = negative ?
                                          Setting.issue_list_summable_columns - ["cf_#{custom_field.id}"] :
                                          Setting.issue_list_summable_columns << "cf_#{custom_field.id}"
end

Given /^the custom field "(.*?)" is activated for type "(.*?)"$/ do |field_name, type_name|
  custom_field = WorkPackageCustomField.find_by_name(field_name)
  type = Type.find_by_name(type_name)
  custom_field.types << type
end

Given /^there are no custom fields$/ do
  CustomField.destroy_all
end

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

Given /^the following languages are active:$/ do |table|
  Setting.available_languages = table.raw.flatten
end

Given /^the (.+) called "(.+)" has the following localizations:$/ do |model_name, object_name, table|
  model = model_name.downcase.gsub(/\s/, "_").camelize.constantize
  object = model.find_by_name(object_name)

  object.translations = []

  table.hashes.each do |h|
    h.each do |k, v|
      h[k] = nil if v == "nil"
    end

    object.translations.create h
  end
end

When /^I delete the (.+) localization of the "(.+)" attribute$/ do |language, attribute|
  locale = locale_for_language language

  page.should have_selector("span.#{attribute}_translation :first-child")
  spans = page.all(:css, "span.#{attribute}_translation")
  # Use the [] method since Firefox doesn't change the 'selected' attribute
  # when choosing the last available option of a select where all other
  # options are disabled. Check scenario 'Deleting a newly added localization'
  # when changing this.
  span = spans.detect do |span|
    span.find(:css, ".locale_selector")["value"] == locale
  end

  destroy = span.find(:css, "a.destroy_locale")

  destroy.click
end

When /^I change the (.+) localization of the "(.+)" attribute to be (.+)$/ do |language, attribute, new_language|
  attribute_span = span_for_localization language, attribute

  locale_selector = attribute_span.find(:css, ".locale_selector")

  locale_name = locale_selector.all(:css, "option").detect{ |o| o.value == locale_for_language(new_language) }
  locale_selector.select(locale_name.text) if locale_name
end

When /^I add the (.+) localization of the "(.+)" attribute as "(.+)"$/ do |language, attribute, value|
  # Emulate old find behavior, just use first match. Better would be
  # selecting an element by id.
  attribute_p = page.find(:xpath, "(//span[contains(@class, '#{attribute}_translation')])[1]/..")
  add_link = attribute_p.find(:css, ".add_locale")
  add_link.click
  span = attribute_p.all(:css, ".#{attribute}_translation").last

  update_localization(span, language, value)
end

# Maybe this step can replace 'I change the ... localization of the ... attribute'
When /^I set the (.+) localization of the "(.+)" attribute to "(.+)"$/ do |language, attribute, value|
  locale = locale_for_language language

  # Look for a span with #{attribute}_translation class, which doesn't have an
  # ancestor with style display: none
  span = page.find(:xpath, "//span[contains(@class, '#{attribute}_translation') " +
                    "and not(ancestor-or-self::*[starts-with(normalize-space(substring-after(@style, 'display:')), 'none')])]")
  update_localization(span, language, value)
end

def update_localization(container, language, value)
  new_value = container.find(:css, "input[type=text], textarea")
  new_locale = container.find(:css, ".locale_selector")

  new_value.set(value.gsub("\\n", "\n"))

  locale_name = new_locale.all(:css, "option").detect{|o| o.value == locale_for_language(language)}
  new_locale.select(locale_name.text) if locale_name
end

Then /^there should be the following localizations:$/ do |table|
  cleaned_expectation = table.hashes.map do |x|
    x.reject{ |k, v| v == "nil" }
  end

  attributes = []

  page.should have_selector(:xpath, '(//*[contains(@name, "translations_attributes") and not(contains(@disabled,"disabled"))])[1]')

  attributes = page.all(:css, "[name*=\"translations_attributes\"]:not([disabled=disabled])")

  name_regexp = /\[(\d)+\]\[(\w+)\]$/

  attribute_group = attributes.inject({}) do |h, element|
    if element['name'] =~ name_regexp
      h[$1] ||= []
      h[$1] << element
    end
    h
  end

  actual_localizations = attribute_group.inject([]) do |a, (k, group)|
    a << group.inject({}) do |h, element|
      if element['name'] =~ name_regexp

        if $2 != "id" and
          $2 != "_destroy" and
          (element['type'] != 'checkbox' or (element['type'] == 'checkbox' and element.checked?))

          h[$2] = element['value']
        end
      end

      h
    end

    a
  end

  actual_localizations = actual_localizations.group_by{|e| e["locale"]}.collect{|(k, v)| v.inject({}){|a, x| a.merge(x)} }

  actual_localizations.should =~ cleaned_expectation
end

Then /^the delete link for the (.+) localization of the "(.+)" attribute should not be visible$/ do |locale, attribute_name|
  attribute_span = span_for_localization locale, attribute_name

  attribute_span.find(:css, "a.destroy_locale").should_not be_visible
end

def span_for_localization language, attribute
  locale = locale_for_language language

  attribute_spans = page.all(:css, "span.#{attribute}_translation")

  attribute_spans.detect do |attribute_span|
    attribute_span.find(:css, ".locale_selector")["value"] == locale &&
    attribute_span.visible?
  end
end

def locale_for_language language
   { "german" => "de", "english" => "en", "french" => "fr" }[language]
end

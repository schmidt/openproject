#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2011 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'action_view/helpers/form_helper'

class TabularFormBuilder < ActionView::Helpers::FormBuilder
  include Redmine::I18n
  include ActionView::Helpers::AssetTagHelper

  def initialize(object_name, object, template, options, proc)
    set_language_if_valid options.delete(:lang)
    super
  end

  (field_helpers - %w(radio_button hidden_field fields_for label) + %w(date_select)).each do |selector|
    src = <<-END_SRC
    def #{selector}(field, options = {})
      if options[:multi_locale] || options[:single_locale]

        localized_field = Proc.new do |translation_form, multiple|
          localized_field(translation_form, __method__, field, options)
        end

        ret = label_for_field(field, options)

        translation_objects = translation_objects field, options

        fields_for(:translations, translation_objects, :builder => ActionView::Helpers::FormBuilder) do |translation_form|
          ret.concat localized_field.call(translation_form)
        end

        if options[:multi_locale]
          ret.concat add_localization_link
        end

        ret
      else
        label_for_field(field, options) + super
      end
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end

  def select(field, choices, options = {}, html_options = {})
    label_for_field(field, options) + super
  end

  private

  # Returns a label tag for the given field
  def label_for_field(field, options = {})
      return '' if options.delete(:no_label)
      text = options[:label].is_a?(Symbol) ? l(options[:label]) : options[:label]
      text ||= l(("field_" + field.to_s.gsub(/\_id$/, "")).to_sym)
      text += @template.content_tag("span", " *", :class => "required") if options.delete(:required)
      @template.label(@object_name, field.to_s, text,
                                     :class => (@object && @object.errors[field] ? "error" : nil))
  end

  def localized_field(translation_form, method, field, options)
    ret = "<span class=\"translation #{field.to_s}_translation\">"

    field_options = localized_options options, translation_form.object.locale

    ret.concat translation_form.send(method, field, field_options)
    ret.concat translation_form.hidden_field :id,
                                             :class => 'translation_id'
    if options[:multi_locale]
      ret.concat translation_form.select :locale,
                                         Setting.available_languages.map { |lang| [ ll(lang.to_s, :general_lang_name), lang.to_sym ] },
                                         {},
                                         :class => 'locale_selector'
      ret.concat translation_form.hidden_field '_destroy',
                                               :disabled => true,
                                               :class => 'destroy_flag',
                                               :value => "1"
      ret.concat '<a href="#" class="destroy_locale icon icon-del" title="Delete"></a>'
      ret.concat "<br>"
    else
      ret.concat translation_form.hidden_field :locale,
                                               :class => 'locale_selector'
    end

    ret.concat "</span>"

    ret
  end

  def translation_objects field, options
    if options[:multi_locale]
      multi_translation_object field, options
    elsif options[:single_locale]
      single_translation_object field, options
    end
  end

  def single_translation_object field, options
    if self.object.translations.detect{ |t| t.locale == :en }.nil?
      self.object.translations.build :locale => :en
    end

    self.object.translations.select{ |t| t.locale == :en }
  end

  def multi_translation_object field, options
    if self.object.translations.size == 0
      self.object.translations.build :locale => user_locale
      self.object.translations
    else
      translations = self.object.translations.select do |t|
        t.send(field).present?
      end

      if translations.size > 0
        translations
      else
        self.object.translations.detect{ |t| t.locale == user_locale} ||
        self.object.translations.first
      end

    end
  end

  def add_localization_link
    "<a href=\"#\" class=\"add_locale\">#{l(:button_add)}</a>"
  end

  def localized_options options, locale = :en
    localized_options = options.clone
    localized_options[:value] = localized_options[:value][locale] if options[:value].is_a?(Hash)
    localized_options.delete(:single_locale)
    localized_options.delete(:multi_locale)

    localized_options
  end

  def user_locale
    User.current.language.present? ?
      User.current.language.to_sym :
      Setting.default_language.to_sym
  end
end

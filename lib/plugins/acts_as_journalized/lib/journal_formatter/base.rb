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

class JournalFormatter::Base
  # unloadable

  include Redmine::I18n
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers
  include ERB::Util

  def initialize(journal)
    @journal = journal
  end

  def render(key, values, options = { :no_html => false })

    label, old_value, value = format_details(key, values)

    unless options[:no_html]
      label, old_value, value = *format_html_details(label, old_value, value)
    end

    render_ternary_detail_text(label, value, old_value)
  end

  private

  def format_details(key, values, options = {})
    label = label(key)

    old_value = values.first
    value = values.last

    [label, old_value, value]
  end

  def format_html_details(label, old_value, value)
    label = content_tag('strong', label)
    old_value = content_tag("i", h(old_value)) if old_value && !old_value.blank?
    old_value = content_tag("strike", old_value) if old_value and value.blank?
    value = content_tag("i", h(value)) if value.present?
    value ||= ""

    [label, old_value, value]
  end

  def label(key)
    @journal.journaled.class.human_attribute_name(key)
  end

  def render_ternary_detail_text(label, value, old_value)
    unless value.blank?
      unless old_value.blank?

        l(:text_journal_changed, :label => label, :old => old_value, :new => value)

      else

        l(:text_journal_set_to, :label => label, :value => value)

      end
    else

      l(:text_journal_deleted, :label => label, :old => old_value)

    end

  end

  def render_binary_detail_text(label, value, old_value)
    if value.blank?

      l(:text_journal_deleted, :label => label, :old => old_value)

    else

      l(:text_journal_added, :label => label, :value => value)

    end
  end
end

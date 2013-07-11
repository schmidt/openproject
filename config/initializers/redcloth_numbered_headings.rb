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

module RedCloth3Patch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable

      alias_method_chain :block_textile_prefix, :numbering
    end
  end

  module InstanceMethods

    private

    def block_textile_prefix_with_numbering(text)

      text.replace(prepend_number_to_heading(text))

      block_textile_prefix_without_numbering(text)
    end

    HEADING = /^h(\d)\.(.*)$/ unless defined? HEADING
    NUMBERED_HEADING = /^h(\d)#\.(.*)$/ unless defined? NUMBERED_HEADING

    def prepend_number_to_heading(text)
      if text =~ NUMBERED_HEADING
        level = $1.to_i

        number = get_next_number_or_start_new_numbering level

        new_text = "h#{level}. #{number}#{$2}"
      elsif text =~ HEADING
        reset_numbering
      end

      return new_text.nil? ? text : new_text
    end

    def get_next_number_or_start_new_numbering(level)
      begin
        number = get_number_for_level level
      rescue ArgumentError
        reset_numbering
        number = get_number_for_level level
      end

      number
    end

    def get_number_for_level(level)
      @numbering_provider ||= Redcloth3::NumberingStack.new level

      @numbering_provider.get_next_numbering_for_level level
    end

    def reset_numbering
      @numbering_provider = nil
    end

  end
end

RedCloth3.send(:include, RedCloth3Patch)

module Redcloth3
  class NumberingStack
    def initialize(level)
      @stack = []
      @init_level = level ? level.to_i : 1
    end

    def get_next_numbering_for_level(level)
      internal_level = map_external_to_internal_level level

      increase_numbering_for_level internal_level

      return current_numbering
    end

    private

    def increase_numbering_for_level(level)
      if @stack[level].nil?
        @stack[level] = 1
        fill_nil_levels_with_zero
      else
        @stack[level] += 1
        reset_higher_levels_than level
      end

      return @stack[level]
    end

    def reset_higher_levels_than(level)
      @stack = @stack.slice! 0, level + 1
    end

    def current_numbering
      return @stack.join(".") + "."
    end

    def map_external_to_internal_level(level)
      if level.to_i < @init_level
        raise ArgumentError, "Current level lower than initial level"
      end
      level.to_i - @init_level
    end

    def fill_nil_levels_with_zero
      @stack.map! { |e| e.nil? ? 0 : e}
    end
  end
end

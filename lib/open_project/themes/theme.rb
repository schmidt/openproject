#-- encoding: UTF-8
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

require 'singleton'
require 'open_project/themes/theme_finder'

module OpenProject
  module Themes
    class Theme
      class SubclassResponsibility < StandardError
      end

      class << self
        def inherited(subclass)
          # make all theme classes singletons
          subclass.send :include, Singleton

          # register the theme with the ThemeFinder
          ThemeFinder.register_theme(subclass.instance)
        end

        def new_theme(identifier = nil)
          theme = Class.new(self).instance
          theme.identifier = identifier if identifier
          theme
        end

        def abstract!
          @abstract = true

          # tell ThemeFinder to forget the theme
          ThemeFinder.forget_theme(instance)

          # undefine methods responsible for creating instances
          singleton_class.send :remove_method, *[:new, :allocate, :instance]
        end

        def abstract?
          @abstract
        end
      end

      # 'OpenProject::Themes::GoofyTheme' => :'goofy'
      def identifier
        @identifier ||= self.class.to_s.gsub(/Theme$/, '').demodulize.underscore.dasherize.to_sym
      end
      attr_writer :identifier

      # 'OpenProject::Themes::GoofyTheme' => 'Goofy'
      def name
        @name ||= self.class.to_s.gsub(/Theme$/, '').demodulize.titleize
      end

      def stylesheet_manifest
        "#{identifier}.css"
      end

      def assets_prefix
        identifier.to_s
      end

      def assets_path
        raise SubclassResponsibility, "override this method to point to your theme's assets folder"
      end

      def overridden_images_path
        @overridden_images_path ||= File.join(assets_path, 'images', assets_prefix)
      end

      def overridden_images
        @overridden_images ||= \
          begin
            Dir.chdir(overridden_images_path) { Dir.glob('**/*') }
          rescue Errno::ENOENT # overridden_images_path missing
            []
          end.to_set
      end

      def image_overridden?(source)
        source.in?(overridden_images)
      end

      URI_REGEXP = %r{^[-a-z]+://|^(?:cid|data):|^//}

      def path_to_image(source)
        return source if source =~ URI_REGEXP
        return source if source[0] == ?/

        if image_overridden?(source)
          File.join(assets_prefix, source)
        else
          source
        end
      end

      include Comparable
      delegate :'<=>', :abstract?, to: :'self.class'

      include Singleton
      abstract!
    end
  end
end

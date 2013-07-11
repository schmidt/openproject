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

#  Run all core and plugins specs via
#  rake spec_all 
#
#  Run plugins specs via
#  rake spec_plugins
#
#  A plugin must register for tests via config variable 'plugins_to_test_paths'
#
#  e.g.
#  class Engine < ::Rails::Engine
#    initializer 'register_path_to_rspec' do |app|
#      app.config.plugins_to_test_paths << self.root
#    end
#  end
#

begin
  require "rspec/core/rake_task"

  namespace :spec do
    desc "Run core and plugin specs"
    RSpec::Core::RakeTask.new(:all => :environment) do |t|
      pattern = []
      dirs = get_plugins_to_test
      dirs << File.join(Rails.root).to_s
      dirs.each do |dir|
        if File.directory?( dir )
          pattern << File.join( dir, 'spec', '**', '*_spec.rb' ).to_s
        end
      end
      t.fail_on_error = false
      t.pattern = pattern
    end

    desc "Run plugin specs"
    RSpec::Core::RakeTask.new(:plugins => :environment) do |t|
      pattern = []
      get_plugins_to_test.each do |dir|
        if File.directory?( dir )
          pattern << File.join( dir, 'spec', '**', '*_spec.rb' ).to_s
        end
      end
      t.fail_on_error = false
      t.pattern = pattern
    end
  end
rescue LoadError
end

def get_plugins_to_test
  plugin_paths = []
  Rails.application.config.plugins_to_test_paths.each do |dir|
    if File.directory?( dir )
      plugin_paths << File.join(dir).to_s
    end
  end
  plugin_paths
end

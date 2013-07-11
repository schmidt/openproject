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

class ScenarioDisabler
  def self.empty_if_disabled(scenario)
    if self.disabled?(scenario)
      scenario.instance_variable_set(:@steps,::Cucumber::Ast::StepCollection.new([])) 
      true
    else
      false
    end
  end

  def self.disable(options)
    @disabled_scenarios ||= []

    @disabled_scenarios << options
  end

  def self.disabled?(scenario)
    #we have to check whether the scenario actually has a feature because there can also be scenario outlines
    #as described in https://github.com/cucumber/cucumber/wiki/Scenario-Outlines and the variables definition is
    #also matched as a scenario
    @disabled_scenarios.present? && scenario.respond_to?(:feature) && @disabled_scenarios.any? do |disabled_scenario|
      disabled_scenario[:feature] == scenario.feature.name && disabled_scenario[:scenario] == scenario.name
    end
  end

end

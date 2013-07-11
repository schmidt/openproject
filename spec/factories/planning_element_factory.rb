#encoding: utf-8
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

FactoryGirl.define do
  factory(:planning_element, :class => PlanningElement) do

    prepared_names = [
      "Backup",
      "BzA",
      "Design",
      "Detailed Design",
      "Development",
      "Feasability Study",
      "Impact Analysis",
      "Integrationstest",
      "New Testing",
      "PNPA",
      "Preproduction",
      "Realization",
      "Reporting",
      "Rollout",
      "Specification",
      "Superelement",
      "Test",
      "Testdurchführung",
      "Testing",
      "Testplanung",
      "Testplanung",
      "Testspezifikation"
    ]

    sequence(:subject) { |n| "#{prepared_names.sample} No. #{n}" }
    sequence(:description) { |n| "Planning Element No. #{n} is the most important part of the project." }

    sequence(:start_date) { |n| ((n - 1) * 7).days.since.to_date }
    sequence(:end_date)   { |n| (n * 7).days.since.to_date }

    association :project
  end
end

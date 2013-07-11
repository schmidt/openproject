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
  factory :project do
    sequence(:name) { |n| "My Project No. #{n}" }
    sequence(:identifier) { |n| "myproject_no_#{n}" }
    enabled_module_names Redmine::AccessControl.available_project_modules

    factory :public_project do
      is_public true
    end

    factory :project_with_trackers do
      after :build do |project|
        project.trackers << FactoryGirl.build(:tracker)
      end
      after :create do |project|
        project.trackers.each { |tracker| tracker.save! }
      end

      factory :valid_project do
        after :build do |project|
          project.trackers << FactoryGirl.build(:tracker_with_workflow)
        end
      end
    end
  end
end

FactoryGirl.define do
  factory(:timelines_project, :class => Project) do

    sequence(:name) { |n| "Project #{n}" }
    sequence(:identifier) { |n| "project#{n}" }

    # activate timeline module

    after_create do |project|
      project.enabled_module_names += ["timelines"]
    end

    # add user to project

    after_create do |project|

      role = FactoryGirl.create(:role)
      member = FactoryGirl.build(:member,
                             # we could also just make everybody a member,
                             # since for now we can't pass transient
                             # attributes into factory_girl
                             :user => project.responsible,
                             :project => project)
      member.roles = [role]
      member.save!
    end

    # generate planning elements

    after_create do |project|

      start_date = rand(18.months).ago
      end_date = start_date

      (5 + rand(20)).times do

        end_date = start_date + (rand(30) + 10).days
        FactoryGirl.create(:planning_element, :project => project,
                                                    :start_date => start_date,
                                                    :end_date => end_date)
        start_date = end_date

      end
    end

    # create a timeline in that project

    after_create do |project|
      FactoryGirl.create(:timeline, :project => project)
    end

  end
end

FactoryGirl.define do
  factory(:uerm_project, :parent => :project) do
    sequence(:name) { |n| "ÜRM Project #{n}" }

    @project_types = Array.new
    @planning_element_types = Array.new
    @colors = PlanningElementTypeColor.ms_project_colors

    # create some project types

    after_create do |project|
      if (@project_types.empty?)

        6.times do
          @project_types << FactoryGirl.create(:project_type)
        end

      end
    end

    # create some planning_element_types

    after_create do |project|

      20.times do
        planning_element_type = FactoryGirl.create(:planning_element_type)
        planning_element_type.color = @colors.sample
        planning_element_type.save

        @planning_element_types << planning_element_type
      end

    end


    after_create do |project|

      projects = Array.new

      # create some projects
      #
      50.times do
        projects << FactoryGirl.create(:project,
                                   :responsible => project.responsible)
      end

      projects << FactoryGirl.create(:project,
                                 :responsible => project.responsible)

      projects.each do |r|

        # give every project a project type

        r.project_type = @project_types.sample
        r.save

        # create a reporting to ürm

        FactoryGirl.create(:reporting,
                       :project => r,
                       :reporting_to_project => project)

        # give every planning element a planning element type

        r.planning_elements.each do |pe|
          pe.planning_element_type = @planning_element_types.sample
          pe.save!
        end

        # Add a timeline with history

        FactoryGirl.create(:timeline_with_history, :project => r)

      end

    end
  end

end

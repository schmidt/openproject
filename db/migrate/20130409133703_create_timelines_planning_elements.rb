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

class CreateTimelinesPlanningElements < ActiveRecord::Migration
  def self.up
    create_table(:timelines_planning_elements) do |t|
      t.column :name,        :string,  :null => false
      t.column :description, :text
      t.column :planning_element_status_comment, :text

      t.column :start_date, :date, :null => false
      t.column :end_date,   :date, :null => false

      t.belongs_to :parent
      t.belongs_to :project
      t.belongs_to :responsible
      t.belongs_to :planning_element_type
      t.belongs_to :planning_element_status

      t.timestamps
    end

    add_index :timelines_planning_elements, :parent_id
    add_index :timelines_planning_elements, :project_id
    add_index :timelines_planning_elements, :responsible_id
    add_index :timelines_planning_elements, :planning_element_type_id
    add_index :timelines_planning_elements, :planning_element_status_id
  end

  def self.down
    drop_table(:timelines_planning_elements)
  end
end

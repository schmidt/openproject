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

class Workflow < ActiveRecord::Base
  belongs_to :role
  belongs_to :old_status, :class_name => 'IssueStatus', :foreign_key => 'old_status_id'
  belongs_to :new_status, :class_name => 'IssueStatus', :foreign_key => 'new_status_id'

  #attr_protected :role_id

  validates_presence_of :role, :old_status, :new_status

  # Returns workflow transitions count by type and role
  def self.count_by_type_and_role
    counts = connection.select_all("SELECT role_id, type_id, count(id) AS c FROM #{Workflow.table_name} GROUP BY role_id, type_id")
    roles = Role.find(:all, :order => 'builtin, position')
    types = Type.find(:all, :order => 'position')

    result = []
    types.each do |type|
      t = []
      roles.each do |role|
        row = counts.detect {|c| c['role_id'].to_s == role.id.to_s && c['type_id'].to_s == type.id.to_s}
        t << [role, (row.nil? ? 0 : row['c'].to_i)]
      end
      result << [type, t]
    end

    result
  end

  # Find potential statuses the user could be allowed to switch issues to
  def self.available_statuses(project, user=User.current)
    Workflow.find(:all,
                  :include => :new_status,
                  :conditions => {:role_id => user.roles_for_project(project).collect(&:id)}).
      collect(&:new_status).
      compact.
      uniq.
      sort
  end

  # Copies workflows from source to targets
  def self.copy(source_type, source_role, target_types, target_roles)
    unless source_type.is_a?(Type) || source_role.is_a?(Role)
      raise ArgumentError.new("source_type or source_role must be specified")
    end

    target_types = Array(target_types)
    target_types = Type.all if target_types.empty?

    target_roles = Array(target_roles)
    target_roles = Role.all if target_roles.empty?

    target_types.each do |target_type|
      target_roles.each do |target_role|
        copy_one(source_type || target_type,
                   source_role || target_role,
                   target_type,
                   target_role)
      end
    end
  end

  # Copies a single set of workflows from source to target
  def self.copy_one(source_type, source_role, target_type, target_role)
    unless source_type.is_a?(Type) && !source_type.new_record? &&
      source_role.is_a?(Role) && !source_role.new_record? &&
      target_type.is_a?(Type) && !target_type.new_record? &&
      target_role.is_a?(Role) && !target_role.new_record?

      raise ArgumentError.new("arguments can not be nil or unsaved objects")
    end

    if source_type == target_type && source_role == target_role
      false
    else
      transaction do
        delete_all :type_id => target_type.id, :role_id => target_role.id
        connection.insert "INSERT INTO #{Workflow.table_name} (type_id, role_id, old_status_id, new_status_id)" +
                          " SELECT #{target_type.id}, #{target_role.id}, old_status_id, new_status_id" +
                          " FROM #{Workflow.table_name}" +
                          " WHERE type_id = #{source_type.id} AND role_id = #{source_role.id}"
      end
      true
    end
  end
end

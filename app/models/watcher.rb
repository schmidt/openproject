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

class Watcher < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :watchable, :polymorphic => true
  belongs_to :user

  attr_accessible :watchable, :user, :user_id

  validates_presence_of :watchable, :user
  validates_uniqueness_of :user_id, :scope => [:watchable_type, :watchable_id]

  validate :validate_active_user
  validate :validate_user_allowed_to_watch

  # Unwatch things that users are no longer allowed to view
  def self.prune(options={})
    if options.has_key?(:user)
      prune_single_user(options[:user], options)
    else
      pruned = 0
      User.find(:all, :conditions => "id IN (SELECT DISTINCT user_id FROM #{table_name})").each do |user|
        pruned += prune_single_user(user, options)
      end
      pruned
    end
  end

  protected

  def validate_active_user
    return if user.blank?
    errors.add :user_id, :invalid unless user.active?
  end

  def validate_user_allowed_to_watch
    return if user.blank? || watchable.blank?
    errors.add :user_id, :invalid unless user.in?(watchable.possible_watcher_users)
  end

  private

  def self.prune_single_user(user, options={})
    return unless user.is_a?(User)
    pruned = 0
    find(:all, :conditions => {:user_id => user.id}).each do |watcher|
      next if watcher.watchable.nil?

      if options.has_key?(:project)
        next unless watcher.watchable.respond_to?(:project) && watcher.watchable.project == options[:project]
      end

      if watcher.watchable.respond_to?(:visible?)
        unless watcher.watchable.visible?(user)
          watcher.destroy
          pruned += 1
        end
      end
    end
    pruned
  end
end

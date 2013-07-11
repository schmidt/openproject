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

module WatchersHelper

  # Deprecated method. Use watcher_link instead
  #
  # This method will be removed in ChiliProject 3.0 or later
  def watcher_tag(object, user, options={:replace => 'watcher'})
    ActiveSupport::Deprecation.warn "The WatchersHelper#watcher_tag is deprecated and will be removed in ChiliProject 3.0. Please use WatchersHelper#watcher_link instead. Please also note the differences between the APIs.", caller

    options[:id] ||= options[:replace] if options[:replace].is_a? String

    options[:replace] = Array(options[:replace]).map { |id| "##{id}" }

    watcher_link(object, user, options)
  end

  # Create a link to watch/unwatch object
  #
  # * :replace - a string or array of strings with css selectors that will be updated, whenever the watcher status is changed
  def watcher_link(object, user, options = { :replace => '.watcher_link', :class => 'watcher_link' })
    options = options.with_indifferent_access
    raise ArgumentError, 'Missing :replace option in options hash' if options['replace'].blank?

    return '' unless user && user.logged? && object.respond_to?('watched_by?')

    watched = object.watched_by?(user)

    html_options = options
    path = send(:"#{(watched ? 'unwatch' : 'watch')}_path", :object_type => object.class.to_s.underscore.pluralize,
                                                            :object_id => object.id,
                                                            :replace => options.delete('replace') )
    html_options[:class] = html_options[:class].to_s + (watched ? ' icon icon-fav' : ' icon icon-fav-off')

    method = watched ?
      :delete :
      :post

    label = watched ?
      l(:button_unwatch) :
      l(:button_watch)

    link_to(label, path, html_options.merge(:remote => true, :method => method))
  end

  # Returns a comma separated list of users watching the given object
  def watchers_list(object)
    remove_allowed = User.current.allowed_to?("delete_#{object.class.name.underscore}_watchers".to_sym, object.project)
    lis = object.watchers.collect do |watch|
      s = avatar(watch.user, :size => "16").to_s + link_to_user(watch.user, :class => 'user').to_s
      if remove_allowed
        s += ' ' + link_to(image_tag('red_x.png', :alt => l(:button_delete), :title => l(:button_delete)),
                           watcher_path(watch),
                           :method => :delete,
                           :remote => true,
                           :style => "vertical-align: middle",
                           :class => "delete")
      end
      "<li>#{ s }</li>"
    end
    lis.empty? ? "" : "<ul>#{ lis.join("\n") }</ul>".html_safe
  end
end

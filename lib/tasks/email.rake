#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2011 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++


namespace :redmine do
  namespace :email do

    desc <<-END_DESC
Read an email from standard input.

General options:
  unknown_user=ACTION      how to handle emails from an unknown user
                           ACTION can be one of the following values:
                           ignore: email is ignored (default)
                           accept: accept as anonymous user
                           create: create a user account
  no_permission_check=1    disable permission checking when receiving
                           the email

Issue attributes control options:
  project=PROJECT          identifier of the target project
  status=STATUS            name of the target status
  tracker=TRACKER          name of the target tracker
  category=CATEGORY        name of the target category
  priority=PRIORITY        name of the target priority
  allow_override=ATTRS     allow email content to override attributes
                           specified by previous options
                           ATTRS is a comma separated list of attributes

If you want to set default values for custom fields, set the value similar to
the attributes above, using the name of the custom field as a key.
Custom ields set this way can only contain characters valid for environment
variables, i.e. no punctuation and no whitespace.
Additionally, you need to set the list of the attributes set this way in the
default_attributes list like this:

  default_attributes="CustomField1 CustomField2"

Examples:
  # No project specified. Emails MUST contain the 'Project' keyword:
  rake redmine:email:read RAILS_ENV="production" < raw_email

  # Fixed project and default tracker specified, but emails can override
  # both tracker and priority attributes:
  rake redmine:email:read RAILS_ENV="production" \\
                  project=foo \\
                  tracker=bug \\
                  allow_override=tracker,priority < raw_email
END_DESC

    task :read => :environment do
      options = { :issue => {} }
      default_fields = (ENV['default_fields'] || "").split
      default_fields |= %w[project status tracker category priority fixed_version]
      default_fields.each{ |field| options[:issue][field] = ENV[field] if ENV[field] }

      options[:allow_override] = ENV['allow_override'] if ENV['allow_override']
      options[:unknown_user] = ENV['unknown_user'] if ENV['unknown_user']
      options[:no_permission_check] = ENV['no_permission_check'] if ENV['no_permission_check']

      MailHandler.receive(STDIN.read, options)
    end

    desc <<-END_DESC
Read emails from an IMAP server.

General options:
  unknown_user=ACTION      how to handle emails from an unknown user
                           ACTION can be one of the following values:
                           ignore: email is ignored (default)
                           accept: accept as anonymous user
                           create: create a user account
  no_permission_check=1    disable permission checking when receiving
                           the email

Available IMAP options:
  host=HOST                IMAP server host (default: 127.0.0.1)
  port=PORT                IMAP server port (default: 143)
  ssl=SSL                  Use SSL? (default: false)
  username=USERNAME        IMAP account
  password=PASSWORD        IMAP password
  folder=FOLDER            IMAP folder to read (default: INBOX)

Issue attributes control options:
  project=PROJECT          identifier of the target project
  status=STATUS            name of the target status
  tracker=TRACKER          name of the target tracker
  category=CATEGORY        name of the target category
  priority=PRIORITY        name of the target priority
  allow_override=ATTRS     allow email content to override attributes
                           specified by previous options
                           ATTRS is a comma separated list of attributes

If you want to set default values for custom fields, set the value similar to
the attributes above, using the name of the custom field as a key.
Custom ields set this way can only contain characters valid for environment
variables, i.e. no punctuation and no whitespace.
Additionally, you need to set the list of the attributes set this way in the
default_attributes list like this:

  default_attributes="CustomField1 CustomField2"

Processed emails control options:
  move_on_success=MAILBOX  move emails that were successfully received
                           to MAILBOX instead of deleting them
  move_on_failure=MAILBOX  move emails that were ignored to MAILBOX

Examples:
  # No project specified. Emails MUST contain the 'Project' keyword:

  rake redmine:email:receive_iamp RAILS_ENV="production" \\
    host=imap.foo.bar username=redmine@example.net password=xxx


  # Fixed project and default tracker specified, but emails can override
  # both tracker and priority attributes:

  rake redmine:email:receive_iamp RAILS_ENV="production" \\
    host=imap.foo.bar username=redmine@example.net password=xxx ssl=1 \\
    project=foo \\
    tracker=bug \\
    allow_override=tracker,priority
END_DESC

    task :receive_imap => :environment do
      imap_options = {:host => ENV['host'],
                      :port => ENV['port'],
                      :ssl => ENV['ssl'],
                      :username => ENV['username'],
                      :password => ENV['password'],
                      :folder => ENV['folder'],
                      :move_on_success => ENV['move_on_success'],
                      :move_on_failure => ENV['move_on_failure']}

      options = { :issue => {} }
      default_fields = (ENV['default_fields'] || "").split
      default_fields |= %w[project status tracker category priority fixed_version]
      default_fields.each{ |field| options[:issue][field] = ENV[field] if ENV[field] }

      options[:allow_override] = ENV['allow_override'] if ENV['allow_override']
      options[:unknown_user] = ENV['unknown_user'] if ENV['unknown_user']
      options[:no_permission_check] = ENV['no_permission_check'] if ENV['no_permission_check']

      Redmine::IMAP.check(imap_options, options)
    end

    desc <<-END_DESC
Read emails from an POP3 server.

Available POP3 options:
  host=HOST                POP3 server host (default: 127.0.0.1)
  port=PORT                POP3 server port (default: 110)
  username=USERNAME        POP3 account
  password=PASSWORD        POP3 password
  apop=1                   use APOP authentication (default: false)
  delete_unprocessed=1     delete messages that could not be processed
                           successfully from the server (default
                           behaviour is to leave them on the server)

See redmine:email:receive_imap for more options and examples.
END_DESC

    task :receive_pop3 => :environment do
      pop_options  = {:host => ENV['host'],
                      :port => ENV['port'],
                      :apop => ENV['apop'],
                      :username => ENV['username'],
                      :password => ENV['password'],
                      :delete_unprocessed => ENV['delete_unprocessed']}

      options = { :issue => {} }
      default_fields = (ENV['default_fields'] || "").split
      default_fields |= %w[project status tracker category priority fixed_version]
      default_fields.each{ |field| options[:issue][field] = ENV[field] if ENV[field] }

      options[:allow_override] = ENV['allow_override'] if ENV['allow_override']
      options[:unknown_user] = ENV['unknown_user'] if ENV['unknown_user']
      options[:no_permission_check] = ENV['no_permission_check'] if ENV['no_permission_check']

      Redmine::POP3.check(pop_options, options)
    end

    desc "Send a test email to the user with the provided login name"
    task :test, [:login] => :environment do |task, args|
      include Redmine::I18n
      abort l(:notice_email_error, "Please include the user login to test with. Example: login=example-login") if args[:login].blank?

      user = User.find_by_login(args[:login])
      abort l(:notice_email_error, "User #{args[:login]} not found") unless user && user.logged?

      ActionMailer::Base.raise_delivery_errors = true
      begin
        Mailer.deliver_test(User.current)
        puts l(:notice_email_sent, user.mail)
      rescue Exception => e
        abort l(:notice_email_error, e.message)
      end
    end
  end
end

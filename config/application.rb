require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

# # Load Engine plugin if available
# begin
#   require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')
# rescue LoadError
#   # Not available
# end

module Chiliproject
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W( #{RAILS_ROOT}/app/sweepers )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :journal_observer, :message_observer, :issue_observer, :news_observer, :document_observer, :wiki_content_observer, :comment_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Deliveries are disabled by default. Do NOT modify this section.
    # Define your email configuration in configuration.yml instead.
    # It will automatically turn deliveries on
    config.action_mailer.perform_deliveries = false

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # help rails to find the right assets-path
    # config.action_controller.asset_path = proc { |asset_path|
      # "/reporting#{asset_path}"
    # }

    # Load any local configuration that is kept out of source control
    # (e.g. patches).
    if File.exists?(File.join(File.dirname(__FILE__), 'additional_environment.rb'))
    instance_eval File.read(File.join(File.dirname(__FILE__), 'additional_environment.rb'))
  end
  end

  module EncryptedId
    protected
    def encrypted_id(id, date = Date.today)
      Digest::SHA1.hexdigest date.strftime("#{id}|Geheim2011*|%Y-%m-%d")
    end
  end
end

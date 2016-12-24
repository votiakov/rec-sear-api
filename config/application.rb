require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PkoApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.time_zone = 'Europe/Warsaw'

    config.api_only = true

    config.active_record.belongs_to_required_by_default = true # does not work in new_framework_defaults.rb

    config.generators do |g|
      g.helper false
      g.assets false

      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl

      g.view_specs false
      g.helper_specs false
    end

    config.i18n.available_locales = [:en]
    config.i18n.default_locale = :en

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/services/**/*)
    # config.autoload_paths += %W(#{config.root}/app/models/dictionary/)
    config.autoload_paths += %W(#{config.root}/app/controllers/dicionaries/)

    config.action_mailer.default_url_options = { host: ENV['WEB_CLIENT_HOST'], port: ENV['WEB_CLIENT_PORT'] }

    # config.action_mailer.delivery_method = :file
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address              => "example.com",
      :port                 => 444,
      :user_name            => 'example@example.com',
      :password             => 'password',
      :authentication       => 'plain',
      :enable_starttls_auto => true
    }

  end
end

PkoApi::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.


  # uncomment this line to process sidekiq jobs in foreground
  # require 'sidekiq/testing/inline'


  # uncomment this line to process sidekiq jobs in foreground
  # require 'sidekiq/testing/inline'

  config.web_socket_server_url = "ws://localhost:28080"
  config.action_cable.allowed_request_origins = ['http://0.0.0.0:9001']
  ActionCable.server.config.disable_request_forgery_protection = true


  # config.middleware.insert_before 0, "Rack::Cors" do
  #   allow do
  #     origins '*'
  #     resource '*', headers: :any, methods: [:get, :put, :delete, :post, :options]
  #   end
  # end

  config.active_record.raise_in_transactional_callbacks = true

  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # config.assets.debug = true

  config.asset_host = ENV['ASSET_HOST']

  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = false
    Bullet.bullet_logger = true
    Bullet.rails_logger = true

    Bullet.console = false
    Bullet.growl = false
    Bullet.bugsnag = false
    Bullet.airbrake = false
    Bullet.rollbar = false
    Bullet.add_footer = false
  end
end
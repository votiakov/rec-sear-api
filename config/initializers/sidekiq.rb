Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
    namespace: ENV['REDIS_CHANNEL_PREFIX']
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
    namespace: ENV['REDIS_CHANNEL_PREFIX']
  }
end
require 'sidekiq/web'
# Sidekiq::Web.set :session_secret, Rails.application.secrets.secret_key_base
# Sidekiq::Web.set :sessions, Rails.application.config.session_options
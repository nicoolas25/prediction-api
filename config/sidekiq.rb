require 'sidekiq'

SIDEKIQ_NAMESPACE = 'prediction-api'.freeze

# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_client do |config|
  config.redis = { :namespace => SIDEKIQ_NAMESPACE }
end

# Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
Sidekiq.configure_server do |config|
  config.redis = { :namespace => SIDEKIQ_NAMESPACE }
end

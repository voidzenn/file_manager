Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' } # Replace with your Redis server information
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' } # Replace with your Redis server information
end

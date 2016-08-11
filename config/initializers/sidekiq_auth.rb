# Add basic HTTP authentication to Sidekiq's rack app
require "sidekiq/web"

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
end if Rails.env.production?
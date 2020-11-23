require_relative 'boot'

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pacscl
  class Application < Rails::Application
    config.action_mailer.default_url_options = { host: "http://inherownright.org", from: "admin@inherownright.org" } 
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = :delayed_job

    config.action_mailer.delivery_method = :postmark

    config.action_mailer.postmark_settings = { :api_token => ENV['POSTMARK_API_KEY'] }
  end
end

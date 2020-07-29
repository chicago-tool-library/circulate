require_relative "boot"

require "rails"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
# require 'action_cable/engine'
# require 'action_mailbox/engine'
require "action_text/engine"
require "rails/test_unit/railtie"

# require 'sprockets/railtie'
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Circulate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    # config.autoloader = :classic

    # config.active_storage.variant_processor = :vips
    config.active_job.queue_adapter = :sucker_punch

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    unless ENV['HTTP_BASIC_USERS'].blank?
      config.middleware.use ::Rack::Auth::Basic do |username, password|
          ENV['HTTP_BASIC_USERS'].split(';').any? do |pair|
              [username, password] == pair.split(':')
          end
      end
    end
  end
end

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  html_tag.html_safe
end

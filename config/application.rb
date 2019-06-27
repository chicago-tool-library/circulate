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

    config.active_storage.variant_processor = :vips

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  html_tag.html_safe
end

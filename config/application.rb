require_relative "boot"

require "rails"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "sprockets/railtie"
# require 'action_cable/engine'
# require 'action_mailbox/engine'
require "action_text/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Circulate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.active_record.has_many_inversing = false
    config.active_storage.track_variants = false
    config.active_storage.queues.analysis = :active_storage_analysis
    config.active_job.queue_adapter = :sucker_punch
    config.action_dispatch.cookies_same_site_protection = nil
    config.action_view.form_with_generates_remote_forms = true
    ActiveSupport.utc_to_local_returns_utc_offset_times = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Delegates exception handling to the routes
    config.exceptions_app = routes
  end
end

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  html_tag.html_safe
end

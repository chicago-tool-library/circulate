require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

# We're not using actioncable, but there's a bug that prevents the app from loading when eagerloading is on
# https://github.com/hotwired/turbo-rails/issues/512
require "action_cable/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Circulate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # We use Texters that act like Mailers for SMS communication
    config.autoload_paths << "#{root}/app/texters"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.active_record.has_many_inversing = false
    config.active_storage.track_variants = false
    config.active_storage.queues.analysis = :active_storage_analysis
    # Rails 7 changed the default image processor to :vips; we will have to
    # get it installed in our Heroku environment before we can switch.
    config.active_storage.variant_processor = :mini_magick
    config.active_job.queue_adapter = :sucker_punch
    config.action_dispatch.cookies_same_site_protection = :lax
    config.action_view.form_with_generates_remote_forms = false
    ActiveSupport.utc_to_local_returns_utc_offset_times = false

    # Delegates exception handling to the routes
    config.exceptions_app = routes
  end
end

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  html_tag.html_safe
end

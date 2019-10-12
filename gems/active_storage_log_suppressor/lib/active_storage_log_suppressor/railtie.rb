# frozen_string_literal: true

module ActiveStorageLogSuppressor
  class Railtie < ::Rails::Railtie
    initializer "active_support_log_suppressor.install" do |app|
      if Rails.env.development? && !ENV.fetch("SHOW_ACTIVE_STORAGE_LOGS") { false }
        install!
      end
    end

    # ActiveStorage is really noisy as each image that appears on a page can result in up to two requests being
    # logged through the Rails stack.
    #
    # This code selectively turns off logging in the various Rails components when an ActiveStorage
    # request is detected.
    def install!
      message = "Hiding all ActiveStorage logging in development mode. Disable by setting SHOW_ACTIVE_STORAGE_LOGS."
      puts "[active_storage_log_suppressor] #{red(message)}"

      require "action_controller/log_subscriber"
      ::ActionController::LogSubscriber.send :prepend, ActionControllerLoggingFilters
      require "active_storage/log_subscriber"
      ::ActiveStorage::LogSubscriber.send :prepend, ActiveStorageLoggingFilters
      require "active_record/log_subscriber"
      ::ActiveRecord::LogSubscriber.send :prepend, ActiveRecordLoggingFilters
      require "rails/rack/logger"
      ::Rails::Rack::Logger.send :prepend, RackLoggerLoggingFilters
    end

    def red(message)
      "\e[0;31m#{message}\033[0m"
    end
  end
end

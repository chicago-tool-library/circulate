# frozen_string_literal: true

module ActiveStorageLogSuppressor
  module ActionControllerLoggingFilters
    def start_processing(event)
      super unless event.payload[:controller].start_with? "ActiveStorage::"
    end

    def process_action(event)
      super unless event.payload[:controller].start_with? "ActiveStorage::"
    end

    def redirect_to(event)
      super unless event.payload[:location].include? "/rails/active_storage"
    end
  end

  module ActiveStorageLoggingFilters
    private
    def info(event, colored_message); end
    def debug(event, colored_message); end
  end

  module ActiveRecordLoggingFilters
    def sql(event)
      super unless Thread.current[:__active_support_request]
    end
  end

  module RackLoggerLoggingFilters
    def call_app(request, env)
      instrumenter = ActiveSupport::Notifications.instrumenter
      instrumenter.start "request.action_dispatch", request: request

      if request.path.start_with? "/rails/active_storage"
        Thread.current[:__active_support_request] = true
      else
        logger.info { started_request_message(request) }
      end

      status, headers, body = @app.call(env)
      body = ::Rack::BodyProxy.new(body) { finish(request) }
      [status, headers, body]
    rescue Exception
      finish(request)
      raise
    ensure
      ActiveSupport::LogSubscriber.flush_all!
    end

    def finish(request)
      Thread.current[:__active_support_request] = false
      super
    end
  end
end
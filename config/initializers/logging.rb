# frozen_string_literal: true

# when requests are sent from http.rb gem
ActiveSupport::Notifications.subscribe("start_request.http") do |name, start, finish, id, payload|
  filtered = payload[:request].uri.to_s.gsub(/((?:client_secret|refresh_token)=)[^&]+/, '\1[FILTERED]')
  Rails.logger.info("HTTP #{payload[:request].verb} to #{filtered}")
end

# when requests are completed from http.rb gem
ActiveSupport::Notifications.subscribe("request.http") do |name, start, finish, id, payload|
  Rails.logger.info(
    name:, start: start.to_f, finish: finish.to_f, id:, payload:
  )
end

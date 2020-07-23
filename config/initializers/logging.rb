ActiveSupport::Notifications.subscribe("start_request.http") do |name, start, finish, id, payload|
  filtered = payload[:request].uri.to_s.gsub(/((?:client_secret|refresh_token)=)[^&]+/, '\1[FILTERED]')
  Rails.logger.info("HTTP #{payload[:request].verb} to #{filtered}")
end

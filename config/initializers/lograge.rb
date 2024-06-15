Rails.application.configure do
  config.lograge.enabled = true

  # Set a few custom parameters on log lines
  config.lograge.custom_payload do |controller|
    {
      user_id: controller.current_user.try(:id) || controller.try(:member).try(:user).try(:id),
      request_id: controller.request.request_id
    }
  end

  # Heroku environments will set this env var and expect logs on stdout
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.lograge.logger = ActiveSupport::Logger.new($stdout)
  end
end

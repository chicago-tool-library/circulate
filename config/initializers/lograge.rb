Rails.application.configure do
  config.lograge.enabled = true unless Rails.env.development?

  # Set a few custom parameters on log lines
  config.lograge.custom_payload do |controller|
    {request_id: controller.request.request_id}.tap do |payload|
      user_id = controller.current_user.try(:id) || controller.try(:member).try(:user).try(:id)
      payload[:user_id] = user_id if user_id
    end
  end

  # Heroku environments will set this env var and expect logs on stdout
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.lograge.logger = ActiveSupport::Logger.new($stdout)
  end
end

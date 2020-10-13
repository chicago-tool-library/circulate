unless ENV["HTTP_BASIC_USERS"].blank?
  Rails.application.config.middleware.use ::Rack::Auth::Basic do |username, password|
    ENV["HTTP_BASIC_USERS"].split(";").any? do |pair|
      pair.split(":") == [username, password]
    end
  end

  if Rails.application.config.action_mailer.show_previews
    Rails::MailersController.prepend_before_action do
      head :forbidden unless authenticate_or_request_with_http_basic do |username, password|
        ENV["HTTP_BASIC_USERS"].split(";").any? do |pair|
          pair.split(":") == [username, password]
        end
      end
    end
  end
end

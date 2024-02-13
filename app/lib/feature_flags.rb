class FeatureFlags
  def self.sms_reminders_enabled?
    ENV["FEATURE_SMS_REMINDERS"] == "on"
  end
end

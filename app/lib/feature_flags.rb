class FeatureFlags
  def self.sms_reminders_enabled?
    ENV["FEATURE_SMS_REMINDERS"] == "on"
  end

  def self.new_appointments_page_enabled?(override = nil)
    if override.nil?
      ENV["FEATURE_NEW_APPOINTMENTS_PAGE"] == "on"
    else
      ActiveModel::Type::Boolean.new.cast(override)
    end
  end

  def self.group_lending_enabled?
    ENV["FEATURE_GROUP_LENDING"] == "on"
  end
end

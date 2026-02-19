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

  def self.reservable_items_enabled?
    ENV["FEATURE_RESERVABLE_ITEMS"] == "on"
  end

  def self.for_later_lists_enabled?
    ENV["FOR_LATER_LISTS"] == "on"
  end
end

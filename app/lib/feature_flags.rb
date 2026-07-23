class FeatureFlags
  def self.sms_reminders_enabled?
    ENV["FEATURE_SMS_REMINDERS"] == "on"
  end

  def self.reservable_items_enabled?
    ENV["FEATURE_RESERVABLE_ITEMS"] == "on"
  end

  def self.for_later_lists_enabled?
    ENV["FOR_LATER_LISTS"] == "on"
  end

  def self.stripe_payments_enabled?
    ENV["FEATURE_STRIPE_PAYMENTS"] == "on"
  end
end

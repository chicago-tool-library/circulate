module PickupsHelper
  def pickup_status_options
    Pickup.statuses.map do |key, value|
      [key, key]
    end
  end
end

module Admin
  module HoldsHelper
    def wait_time(hold)
      if hold.active?
        time_ago_in_words(hold.created_at)
      elsif hold.ended_at.present?
        distance_of_time_in_words(hold.created_at, hold.ended_at)
      else
        distance_of_time_in_words(hold.created_at, hold.expires_at)
      end
    end
  end
end

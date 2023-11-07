module Admin
  module HoldsHelper
    def wait_time(hold)
      if hold.active?
        # How long has this person been waiting to pick up this item?
        time_ago_in_words(hold.created_at)
      elsif hold.ended_at.present?
        # How long did this person wait to get this item? Holds are ended when the item
        # is checked out.
        distance_of_time_in_words(hold.created_at, hold.ended_at)
      else
        # How long did this item sit waiting for someone to pick it up (which never happened)?
        distance_of_time_in_words(hold.created_at, hold.expires_at)
      end
    end
  end
end

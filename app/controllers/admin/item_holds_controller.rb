# frozen_string_literal: true

module Admin
  class ItemHoldsController < BaseController
    def index
      @item = Item.find(params[:item_id])
      holds_scope = @item.holds.order(created_at: :asc)
      @holds =
        if params[:inactive]
          holds_scope.inactive
        else
          holds_scope.active
        end
    end

    def wait_time(hold)
      if hold.active?
        helpers.time_ago_in_words(hold.created_at)
      elsif hold.ended_at.present?
        helpers.distance_of_time_in_words(hold.created_at, hold.ended_at)
      else
        helpers.distance_of_time_in_words(hold.created_at, hold.expires_at)
      end
    end

    helper_method :wait_time
  end
end

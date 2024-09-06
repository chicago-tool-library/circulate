module Admin
  module Reports
    class MissingItemsController < BaseController
      def index
        @items = Item.missing.includes(:borrow_policy, last_active_ticket: :latest_ticket_update)
      end
    end
  end
end

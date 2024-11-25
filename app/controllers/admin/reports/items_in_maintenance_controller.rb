module Admin
  module Reports
    class ItemsInMaintenanceController < BaseController
      def index
        @tickets = Ticket.all.includes(item: [:borrow_policy, :categories]).where.not(status: %w[resolved retired])
      end
    end
  end
end

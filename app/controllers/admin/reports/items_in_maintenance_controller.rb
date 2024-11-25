module Admin
  module Reports
    class ItemsInMaintenanceController < BaseController
      def index
        @tickets = ticket_query
          .joins(:item)
          .merge(item_query)
          .includes(item: [:borrow_policy, :categories])
      end

      private

      def ticket_query
        type, column = current_sort
        query = Ticket.all.where.not(status: %w[resolved retired])

        if type == "ticket" && ["title", "status", "created_at", "updated_at"].include?(column)
          query = query.order(column => current_direction)
        end

        query
      end

      def item_query
        type, column = current_sort
        query = Item.all

        if type == "item" && ["number", "status", "name"].include?(column)
          query = query.order(column => current_direction)
        end

        query
      end

      def current_sort
        sort = params[:sort] || "ticket-created_at"
        sort.split("-")
      end

      def current_direction
        params[:direction] || "desc"
      end
    end
  end
end

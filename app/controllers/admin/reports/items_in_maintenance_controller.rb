module Admin
  module Reports
    class ItemsInMaintenanceController < BaseController
      def index
        params[:q] ||= {"s"=>"created_at desc"}
        @q = Ticket.all.where.not(status: %w[resolved retired]).ransack(params[:q])
        @tickets = @q.result.includes(:item)
      end
    end
  end
end

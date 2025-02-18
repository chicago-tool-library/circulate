module Admin
  module Reports
    class ItemsInMaintenanceController < BaseController
      def index
        params[:q] ||= {"s" => "created_at desc"}
        @q = Ticket.all.where.not(status: %w[resolved retired]).has_tags(params[:tags_name_in]).ransack(params[:q])
        @tickets = @q.result.includes(:item)
      end

    end
  end
end

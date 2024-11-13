module Admin
  module Items
    class TicketsController < BaseController
      before_action :set_ticket, only: %i[show edit update destroy]

      def index
        @tickets = @item.tickets.all.order(:status, updated_at: :desc)
      end

      def show
        @ticket_updates = @ticket.ticket_updates.includes(:audit)

        @events = @ticket_updates.to_a.concat(@ticket.audits).sort_by(&:created_at)
      end

      def new
        @ticket = Ticket.new
      end

      def edit
      end

      def create
        @ticket = @item.tickets.new(ticket_params)

        if @ticket.save
          redirect_to admin_item_ticket_url(@item, @ticket), success: "Ticket was successfully created.", status: :see_other
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @ticket.update(ticket_params)
          redirect_to admin_item_ticket_url(@item, @ticket), success: "Ticket was successfully updated.", status: :see_other
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @ticket.destroy
        redirect_to admin_item_tickets_url(@item), success: "Ticket was successfully destroyed.", status: :see_other
      end

      private

      def set_ticket
        @ticket = Ticket.find(params[:id])
      end

      def ticket_params
        params.require(:ticket).permit(:title, :body, :status).merge(creator_id: current_user.id)
      end
    end
  end
end

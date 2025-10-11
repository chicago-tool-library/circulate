module Admin
  module Items
    module Tickets
      class TicketUpdatesController < BaseController
        before_action :set_ticket
        before_action :set_ticket_update, only: [:edit, :update, :destroy]

        def new
          @ticket_update_form = TicketUpdateForm.new(@ticket)
        end

        def edit
        end

        def create
          @ticket_update_form = TicketUpdateForm.new(@ticket, ticket_update_create_params)

          if @ticket_update_form.save
            redirect_to admin_item_ticket_url(@item, @ticket), success: "Ticket update was successfully created.", status: :see_other
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          if @ticket_update.update(ticket_update_update_params)
            redirect_to admin_item_ticket_url(@item, @ticket), success: "Ticket update was successfully saved.", status: :see_other
          else
            render :edit, status: :unprocessable_content
          end
        end

        def destroy
          @ticket_update.destroy
          redirect_to admin_item_ticket_url(@item, @ticket), success: "Ticket update was successfully destroyed.", status: :see_other
        end

        private

        def set_ticket
          @ticket = @item.tickets.find(params[:ticket_id])
        end

        def set_ticket_update
          @ticket_update = @ticket.ticket_updates.find(params[:id])
        end

        def ticket_update_create_params
          params.require(:ticket_update_form).permit(:title, :time_spent, :body, :status).merge(creator: current_user)
        end

        def ticket_update_update_params
          params.require(:ticket_update).permit(:title, :time_spent, :body)
        end
      end
    end
  end
end

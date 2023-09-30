# frozen_string_literal: true

module Admin
  module Items
    module Tickets
      class TicketUpdatesController < BaseController
        before_action :set_ticket
        before_action :set_ticket_update, only: [:edit, :update, :destroy]

        # def index
        #   @maintenance_reports = @item.maintenance_reports.includes(:audit)

        #   @events = @maintenance_reports.to_a.concat(@item.audits.includes(:maintenance_report)).sort_by(&:created_at)
        # end

        def new
          @ticket_update_form = TicketUpdateForm.new(@ticket)
        end

        def edit
        end

        def create
          @ticket_update_form = TicketUpdateForm.new(@ticket, ticket_update_create_params)

          if @ticket_update_form.save
            redirect_to admin_item_ticket_url(@item, @ticket), success: "Ticket update was successfully created."
          else
            render :new, status: :unprocessable_entity
          end
        end

        def update
          if @ticket_update.update(ticket_update_update_params)
            redirect_to admin_item_ticket_url(@item, @ticket), success: "Ticket update was successfully saved."
          else
            render :edit, status: :unprocessable_entity
          end
        end

        def destroy
          @ticket_update.destroy
          redirect_to admin_item_ticket_url(@item, @ticket), success: "Ticket update was successfully destroyed."
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

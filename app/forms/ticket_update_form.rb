# frozen_string_literal: true

class TicketUpdateForm
  include ActiveModel::Model

  TICKET_UPDATE_ATTRIBUTES = %w[body time_spent creator]
  TICKET_ATTRIBUTES = %w[status]

  delegate(*TICKET_UPDATE_ATTRIBUTES, to: :@ticket_update)
  delegate(:status, to: :@ticket)

  def initialize(ticket, params = {})
    @ticket = Ticket.find(ticket.id)
    @ticket_update = @ticket.ticket_updates.new(params.slice(*TICKET_UPDATE_ATTRIBUTES))
    @ticket.status = params[:status] if params.present?
  end

  def errors
    errs = @ticket_update.errors.dup
    errs.merge! @ticket.errors
    errs
  end

  def self.validators
    TicketUpdate.validators
  end

  def save
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless save_all
      true
    end
  end

  def save_all
    if @ticket.changed?
      return false unless @ticket.save
      @ticket_update.audit = @ticket.reload.audits.last
    end
    @ticket_update.save
  end
end

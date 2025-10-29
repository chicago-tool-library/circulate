class TicketUpdateForm
  include ActiveModel::Model

  TICKET_UPDATE_ATTRIBUTES = %w[body time_spent creator]
  TICKET_ATTRIBUTES = %w[status]
  ITEM_ATTRIBUTES = %w[retired_reason]

  delegate(*TICKET_UPDATE_ATTRIBUTES, to: :@ticket_update)
  delegate(:status, to: :@ticket)
  delegate(:retired_reason, to: :@item)

  def initialize(ticket, params = {})
    @ticket = Ticket.find(ticket.id)
    @ticket_update = @ticket.ticket_updates.new(params.slice(*TICKET_UPDATE_ATTRIBUTES))
    @item = @ticket.item
    @ticket.status = params[:status] if params.present?
    if Ticket.statuses[:retired] == @ticket.status
      @item.status = Item.statuses[:retired]
      @item.retired_reason = params[:retired_reason]
    end
  end

  def errors
    errs = @ticket_update.errors.dup
    errs.merge! @ticket.errors
    errs.merge! @item.errors
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
    @ticket_update.save && @item.save
  end
end

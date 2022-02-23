module TicketsHelper
  def ticket_status_options
    Ticket.statuses.map do |key, value|
      description = " (#{Ticket::STATUS_DESCRIPTIONS[key]})" if Ticket::STATUS_DESCRIPTIONS[key]
      ["#{Ticket::STATUS_NAMES[key]}#{description}", key]
    end
  end

  def audit_ticket_status(audit)
    status_change = audit.audited_changes["status"]
    case status_change
    when Array
      ticket_status_name(status_change[1])
    when String
      ticket_status_name(status_change)
    end
  end

  def ticket_status_name(status)
    Ticket::STATUS_NAMES[status]
  end
end

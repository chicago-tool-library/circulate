module MaintenanceReportsHelper
  # Some of the events in the maintenance report index shouldn't appear to be visually connected to
  # other updates. This groups the reports visually and gives a better sense of an item's story.
  def disconnected_maintenance_report_event?(event)
    status = case event
    when MaintenanceReport
      event.current_item_status
    when ItemAudit
      # TODO refactor this to use the underlying value and not the titlecased label
      audit_item_status(event)&.downcase
    end
    ["retired", "active"].include?(status)
  end
end

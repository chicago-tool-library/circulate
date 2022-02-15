class MaintenanceReportForm
  include ActiveModel::Model

  MAINTENANCE_REPORT_ATTRIBUTES = %w[
    title body time_spent creator
  ]

  ITEM_ATTRIBUTES = %w[status]

  delegate(*MAINTENANCE_REPORT_ATTRIBUTES, to: :@maintenance_report)
  delegate(:status, to: :@item)

  def initialize(item, params = {})
    @item = item
    @maintenance_report = @item.maintenance_reports.new(params.slice(*MAINTENANCE_REPORT_ATTRIBUTES))
    @item.status = params[:status] if params.present?
  end

  def errors
    errs = @maintenance_report.errors.dup
    errs.merge! @item.errors
    errs
  end

  def self.validators
    MaintenanceReport.validators
  end

  def save
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless save_all
      true
    end
  end

  # This is a little bananas, but by controlling the order that the item and maintenance are saved,
  # it becomes a lot easier to group with and work with the data since the status changes recorded
  # as audits will bound any maintenance reports.
  def save_all
    if @item.changed?
      return false unless @item.save
      @maintenance_report.audit = @item.audits.last
    end
    @maintenance_report.current_item_status = @item.status
    @maintenance_report.save
  end
end

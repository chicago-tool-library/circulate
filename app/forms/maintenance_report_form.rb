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
    @item.status = params[:status]
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
      raise ActiveRecord::Rollback unless @maintenance_report.save && @item.save
      true
    end
  end
end

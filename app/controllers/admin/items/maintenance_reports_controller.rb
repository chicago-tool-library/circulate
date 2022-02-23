module Admin
  module Items
    class MaintenanceReportsController < BaseController
      before_action :set_maintenance_report, only: %i[edit update destroy]

      def index
        @maintenance_reports = @item.maintenance_reports.includes(:audit)

        @events = @maintenance_reports.to_a.concat(@item.audits.includes(:maintenance_report)).sort_by(&:created_at)
      end

      def new
        @maintenance_report_form = MaintenanceReportForm.new(@item)
      end

      def edit
      end

      def create
        @maintenance_report_form = MaintenanceReportForm.new(@item, maintenance_report_create_params)

        if @maintenance_report_form.save
          redirect_to admin_item_maintenance_reports_url(@item), success: "Maintenance report was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @maintenance_report.update(maintenance_report_update_params)
          redirect_to admin_item_maintenance_reports_url(@item), success: "Maintenance report was successfully updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @maintenance_report.destroy
        redirect_to admin_item_maintenance_reports_url(@item), success: "Maintenance report was successfully destroyed."
      end

      private

      def set_maintenance_report
        @maintenance_report = @item.maintenance_reports.find(params[:id])
      end

      def maintenance_report_create_params
        params.require(:maintenance_report_form).permit(:title, :time_spent, :body, :status).merge(creator: current_user)
      end

      def maintenance_report_update_params
        params.require(:maintenance_report).permit(:title, :time_spent, :body)
      end
    end
  end
end

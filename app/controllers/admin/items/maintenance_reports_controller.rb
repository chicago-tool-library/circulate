module Admin
  module Items
    class MaintenanceReportsController < BaseController
      before_action :set_maintenance_report, only: %i[show edit update destroy]

      def index
        @maintenance_reports = @item.maintenance_reports
      end

      def show
      end

      def new
        @maintenance_report = MaintenanceReport.new
      end

      def edit
      end

      def create
        @maintenance_report = @item.maintenance_reports.new(maintenance_report_params)

        if @maintenance_report.save
          redirect_to admin_item_maintenance_reports_url(@item), success: "Maintenance report was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @maintenance_report.update(maintenance_report_params)
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

      def maintenance_report_params
        params.require(:maintenance_report).permit(:time_spent, :body).merge(creator: current_user)
      end
    end
  end
end

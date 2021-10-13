module Admin
  module Reports
    class NotificationsController < BaseController
      include Pagy::Backend

      def index
        scope = if params[:member_id]
          Member.find(params[:member_id]).notifications
        else
          Notification
        end
        @pagy, @notifications = pagy(scope.includes(:member).order(created_at: :desc))
      end
    end
  end
end

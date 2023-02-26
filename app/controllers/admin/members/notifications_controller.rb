module Admin
  module Members
    class NotificationsController < BaseController
      include Pagy::Backend

      def index
        @pagy, @notifications = pagy(@member.notifications.order(created_at: :desc))
      end
    end
  end
end

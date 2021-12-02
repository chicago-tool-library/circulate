module Admin
  module Members
    class BaseController < Admin::BaseController
      before_action :load_member

      def are_appointments_enabled?
        if !@current_library.allow_appointments?
          render_not_found
        end
      end

      private

      def load_member
        @member = Member.find(params[:member_id])
      end
    end
  end
end

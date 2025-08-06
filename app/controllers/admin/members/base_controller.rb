module Admin
  module Members
    class BaseController < Admin::BaseController
      before_action :load_member
      before_action :load_notes

      def are_appointments_enabled?
        if !@current_library.allow_appointments?
          render_not_found
        end
      end

      private

      def load_member
        @member = Member.find(params[:member_id])
      end

      def load_notes
        @notes = @member&.notes&.pinned_first
      end
    end
  end
end

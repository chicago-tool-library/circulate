module Admin
  module Members
    class BaseController < Admin::BaseController
      before_action :load_member

      private

      def load_member
        @member = Member.find(params[:member_id])
      end
    end
  end
end

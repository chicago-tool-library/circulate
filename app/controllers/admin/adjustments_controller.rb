module Admin
  class AdjustmentsController < BaseController
    before_action :load_member

    def index
      @adjustments = @member.adjustments.order(created_at: :desc)
    end

    private

    def load_member
      @member = Member.find(params[:member_id])
    end
  end
end

module Admin
  class HoldLoansController < BaseController
    before_action :load_member

    def create
      @member.transaction do
        @member.holds.active.map { |hold|
          Loan.lend(hold.item, to: @member).tap do |loan|
            hold.lend(loan)
          end
        }
      end
      redirect_to admin_member_path(@member)
    end

    private

    def load_member
      @member = Member.find(params[:member_id])
    end
  end
end

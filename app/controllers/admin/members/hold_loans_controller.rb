module Admin
  module Members
    class HoldLoansController < BaseController
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
    end
  end
end

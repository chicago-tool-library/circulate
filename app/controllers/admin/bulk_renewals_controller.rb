module Admin
  class BulkRenewalsController < BaseController
    include ActionView::RecordIdentifier
    include Lending

    before_action :set_member, only: [:update]

    def update
      @member.loans.checked_out.each do |loan|
        renew_loan(loan) if loan.within_renewal_limit?
      end

      redirect_to admin_member_url(@member.id), status: :see_other
    end

    private

    def set_member
      @member = Member.find(params[:id])
    end
  end
end

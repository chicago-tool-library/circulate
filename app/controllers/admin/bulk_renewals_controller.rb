# frozen_string_literal: true

module Admin
  class BulkRenewalsController < BaseController
    include ActionView::RecordIdentifier
    include Lending

    before_action :set_member, only: [:update]

    def update
      @member.loans.checked_out.each do |loan|
        renew_loan(loan) if loan.renewable?
      end

      redirect_to admin_member_url(@member.id)
    end

    private
      def set_member
        @member = Member.find(params[:id])
      end
  end
end

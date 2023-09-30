# frozen_string_literal: true

module Admin
  module Members
    class HoldLoansController < BaseController
      include Lending

      def create
        @member.transaction do
          @member.active_holds.map { |hold| create_loan_from_hold(hold) }
        end
        redirect_to admin_member_path(@member)
      end
    end
  end
end

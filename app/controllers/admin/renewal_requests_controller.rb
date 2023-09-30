# frozen_string_literal: true

module Admin
  class RenewalRequestsController < BaseController
    include Pagy::Backend
    include Lending

    def index
      renewal_requests_scope = RenewalRequest.send(index_filter)
        .order(created_at: :desc)
        .includes(loan: [{ item: :borrow_policy }, :member, :renewals])
      @pagy, @renewal_requests = pagy(renewal_requests_scope, items: 50)
    end

    def update
      return head(:forbidden) unless current_user.admin? || current_user.staff?

      @renewal_request = RenewalRequest.find(params[:id])

      if @renewal_request.loan.ended?
        redirect_to admin_renewal_requests_url, error: "That item is not on loan"
        return
      end

      flash_message = if @renewal_request.update(renewal_request_params)
        renew_loan(@renewal_request.loan) if @renewal_request.approved?
        MemberMailer.with(renewal_request: @renewal_request).renewal_request_updated.deliver_later
        { success: "Renewal request updated." }
      else
        { error: "Something went wrong!" }
      end

      redirect_to admin_renewal_requests_url, flash: flash_message
    end

    private
      def index_filter
        allowed = %w[all requested rejected]
        return params[:filter] if allowed.include? params[:filter]
        "all"
      end

      def renewal_request_params
        params.require(:renewal_request).permit(:status)
      end
  end
end

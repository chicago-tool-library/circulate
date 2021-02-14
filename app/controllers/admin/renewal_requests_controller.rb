module Admin
  class RenewalRequestsController < BaseController
    def update
      return head(:forbidden) unless current_user.admin? || current_user.staff?

      flash_message = if @renewal_request.save
        # TODO: Renew loan
        MemberMailer.with(member: @renewal_request.loan.member, renewal_request: @renewal_request).loan_renewal_request_message.deliver_later
        {success: "Renewal request updated."}
      else
        {error: "Something went wrong!"}
      end

      redirect_to admin_load_summaries_url, flash: flash_message
    end

    private

    def renewal_request_params
      params.require(:renewal_request).permit(:status)
    end
  end
end

class RenewalRequestsController < ApplicationController
  def show
    @renewal_request = RenewalRequest.decrypt(params[:id])
    unless @renewal_request
      render_not_found
      return
    end

    if @renewal_request.expires_at < Time.current
      render :expired, status: :gone
      return
    end

    @member = Member.find(@renewal_request.member_id)
  end
end

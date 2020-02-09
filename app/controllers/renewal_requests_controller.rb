class RenewalRequestsController < ApplicationController
  def show
    @renewal_request = RenewalRequest.decrypt(params[:id])
    if !@renewal_request || @renewal_request.expires_at < Time.current
      render_not_found
      return
    end

    @member = Member.find(@renewal_request.member_id)
  end
end

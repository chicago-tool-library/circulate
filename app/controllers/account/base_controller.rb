module Account
  class BaseController < ApplicationController
    before_action :load_member

    layout "account"

    private

    def load_member
      @member_retriever = MemberRetriever.decrypt(params[:account_id])
      unless @member_retriever
        render_not_found
        return
      end

      if @member_retriever.expires_at < Time.current
        render "account/expired", status: :gone
        return
      end

      @member = Member.find(@member_retriever.member_id)
    end
  end
end

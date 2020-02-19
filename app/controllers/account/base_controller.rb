module Account
  class BaseController < ApplicationController
    layout "account"

    private

    def load_member_from_encrypted_id(encypted_id)
      @member_retriever = MemberRetriever.decrypt(encypted_id)
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

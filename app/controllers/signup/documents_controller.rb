# frozen_string_literal: true

module Signup
  class DocumentsController < BaseController
    before_action :load_member, only: :agreement
    before_action :is_membership_enabled?

    def rules
      @document = Document.borrow_policy
      activate_step(:rules)
    end

    def agreement
      @document = Document.agreement
      @acceptance = AgreementAcceptance.new
      activate_step(:agreement)
    end
  end
end

# frozen_string_literal: true

module Renewal
  class DocumentsController < BaseController
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

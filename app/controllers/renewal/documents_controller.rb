module Renewal
  class DocumentsController < BaseController
    def rules
      @document = Document.borrow_policy.first!
      activate_step(:rules)
    end

    def agreement
      @document = Document.agreement.first!
      @acceptance = AgreementAcceptance.new
      activate_step(:agreement)
    end
  end
end

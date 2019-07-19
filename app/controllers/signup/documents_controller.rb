module Signup
  class DocumentsController < BaseController
    before_action :load_member

    def show
      @document = Document.agreement
      @acceptance = AgreementAcceptance.new
      activate_step(:agreement)
    end
  end
end

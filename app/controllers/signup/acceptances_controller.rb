module Signup
  class AcceptancesController < BaseController
    before_action :load_member
    before_action :load_document

    def create
      @acceptance = @document.acceptances.new(member: @member, terms: document_params[:terms])
      if @acceptance.save
        redirect_to next_signup_step(@document)
      else
        render "signup/documents/show"
      end
    end

    def destroy
    end

    private

    def document_params
      params.require(:document_acceptance).permit(:terms)
    end

    def load_document
      @document = Document.find(params[:document_id])
    end
  end
end

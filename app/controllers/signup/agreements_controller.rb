module Signup
  class DocumentsController < BaseController
    before_action :load_member

    def show
      @document = Document.find(params[:id])
      @acceptance = @document.acceptances.new
      activate_document_step(@document)
    end
  end
end

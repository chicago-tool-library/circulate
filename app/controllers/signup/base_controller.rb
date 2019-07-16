module Signup
  class BaseController < ApplicationController
    before_action :load_documents
    before_action :load_steps

    layout "signup"

    private

    def load_documents
      @documents = Document.active.ordered
    end

    def load_member
      if session[:timeout] < Time.current - 15.minutes
        session.delete :timeout
        session.delete :member_id
        flash[:error] = "Your session expired. Please come into the library to complete signup."
        redirect_to new_signup_member_path
      else
        @member = Member.find(session[:member_id])
      end
    end

    def load_steps
      @steps = [
        Step.new(name: "Profile", tooltip: "Information about you"),
      ]
      @documents.each do |document|
        @steps << Step.new(name: document.name, tooltip: document.summary)
      end
      @steps << Step.new(name: "Membership Fee", tooltip: "")
      @steps << Step.new(name: "Complete", tooltip: "All done!")
    end

    def activate_member_step
      @steps.first.active = true
    end

    def activate_complete_step
      @steps.last.active = true
    end

    def activate_payment_step
      @steps[-2].active = true
    end

    def activate_document_step(document)
      index = @documents.index(document)
      @steps[index + 1].active = true
    end

    def next_signup_step(document = nil)
      next_document = document ? @documents[@documents.index(document) + 1] : @documents.first
      if next_document
        signup_document_path(next_document)
      else
        new_signup_payment_path
      end
    end
  end
end

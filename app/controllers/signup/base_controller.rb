module Signup
  class BaseController < ApplicationController
    before_action :load_agreements
    before_action :load_steps

    private

    def load_agreements
      @agreements = Agreement.active.ordered
    end

    def load_member
      if session[:timeout] < Time.current - 15.minutes
        session.delete :timeout
        session.delete :member_id
        flash[:error] = "Your session expired. Please come into the library to complete signup."
        redirect_to new_signup_member_path
      end
      @member = Member.find(session[:member_id])
    end

    def load_steps
      @steps = [
        Step.new(name: "Profile", tooltip: "Information about you"),
      ]
      @agreements.each do |agreement|
        @steps << Step.new(name: agreement.name, tooltip: agreement.summary)
      end
      @steps << Step.new(name: "Payment", tooltip: "")
      @steps << Step.new(name: "Complete", tooltip: "All done!")
    end

    def activate_member_step
      @steps.first.active = true
    end

    def activate_complete_step
      @steps.last.active = true
    end

    def activate_agreement_step(agreement)
      index = @agreements.index(agreement)
      @steps[index + 1].active = true
    end

    def next_signup_step(agreement = nil)
      next_agreement = agreement ? @agreements[@agreements.index(agreement) + 1] : @agreements.first
      if next_agreement
        signup_agreement_path(next_agreement)
      else
        new_signup_payment_path
      end
    end
  end
end

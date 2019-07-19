module Signup
  class BaseController < ApplicationController
    before_action :load_steps

    layout "signup"

    private

    def load_member
      if session[:member_id] && session[:timeout] && session[:timeout] > Time.current - 15.minutes
        @member = Member.find(session[:member_id])
      else
        session.delete :timeout
        session.delete :member_id
        flash[:error] = "Your session expired. Please come into the library to complete signup."
        redirect_to new_signup_member_url
      end
    end

    def load_steps
      agreement = Document.agreement
      @steps = [ Step.new(:profile, name: "Profile") ]
      @steps << Step.new(:agreement, name: agreement.name)
      @steps << Step.new(:payment, name: "Membership Fee")
      @steps << Step.new(:complete, name: "Complete")
    end

    def activate_step(step_id)
      @steps.each do |step|
        if step.id == step_id
          step.active = true
          return
        end
      end
    end
  end
end

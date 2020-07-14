module Signup
  class BaseController < ApplicationController
    before_action :load_steps
    before_action :set_page_title

    layout "steps"

    private

    def load_member
      if session[:member_id] && session[:timeout] && session[:timeout] > Time.current - 15.minutes
        @member = Member.find(session[:member_id])
      else
        reset_session
        flash[:error] = "Your session expired. Please come into the library to complete signup."
        redirect_to signup_url
      end
    end

    def load_steps
      agreement = Document.agreement
      @steps = [
        Step.new(:rules, name: "Rules"),
        Step.new(:profile, name: "Profile"),
        Step.new(:agreement, name: agreement.name),
        Step.new(:payment, name: "Payment"),
        Step.new(:complete, name: "Complete")
      ]
    end

    def set_page_title
      @page_title = "New Member Signup"
    end

    def activate_step(step_id)
      @steps.each do |step|
        if step.id == step_id
          step.active = true
          @active_step = step
          break
        end
      end
    end
  end
end

module Signup
  class BaseController < ApplicationController
    before_action :load_steps
    before_action :set_page_title

    layout "steps"

    def is_membership_enabled?
      if !@current_library.allow_members?
        render_not_found
      end
    end

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
      @steps = if @current_library.allow_payments?
        [
          Step.new(:rules, name: "Rules"),
          Step.new(:profile, name: "Profile"),
          Step.new(:agreement, name: agreement.name),
          Step.new(:payment, name: "Payment"),
          Step.new(:complete, name: "Complete")
        ]
      else
        [
          Step.new(:rules, name: "Rules"),
          Step.new(:profile, name: "Profile"),
          Step.new(:agreement, name: agreement.name),
          Step.new(:complete, name: "Complete")
        ]
      end
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

    def set_page_title
      @page_title = "New Member Signup"
    end
  end
end

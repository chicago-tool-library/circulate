module Renewal
  class BaseController < ApplicationController
    before_action :authenticate_user!

    before_action :load_steps
    before_action :set_page_title

    layout "steps"

    private

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

    def load_member
      @member = current_member
    end

    def set_page_title
      @page_title = "Membership Renewal"
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

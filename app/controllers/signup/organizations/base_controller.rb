module Signup
  module Organizations
    class BaseController < ApplicationController
      before_action :load_steps

      layout "steps"

      def load_steps
        @steps = [
          Step.new(:policies, name: "Policies"),
          Step.new(:profile, name: "Profile"),
          Step.new(:confirm_email, name: "Confirm Email"),
          Step.new(:approval, name: "Approval")
        ]
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
end

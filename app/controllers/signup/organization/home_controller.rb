module Signup
  module Organization
    class HomeController < ApplicationController
      before_action :load_steps

      layout "steps"

      def cost
        activate_step(:cost)
      end

      def load_steps
        @steps = [
          Step.new(:cost, name: "Cost"),
          Step.new(:profile, name: "Profile")
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

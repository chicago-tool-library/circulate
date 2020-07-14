module Holds
  class BaseController < ApplicationController
    before_action :load_steps
    before_action :set_page_title
    before_action :load_requested_items

    layout "steps"

    private

    # def load_member
    #   if session[:member_id] && session[:timeout] && session[:timeout] > Time.current - 15.minutes
    #     @member = Member.find(session[:member_id])
    #   else
    #     reset_session
    #     flash[:error] = "Your session expired."
    #     redirect_to signup_url
    #   end
    # end

    def load_steps
      @steps = [
        Step.new(:items, name: "Find Items"),
        Step.new(:submit, name: "Submit"),
        Step.new(:complete, name: "Complete")
      ]
    end

    def load_requested_items
      session[:requested_item_ids] ||= []
      @requested_item_ids = session[:requested_item_ids]
      @requested_items = Item.active.where(id: @requested_item_ids).all.sort_by { |item| @requested_item_ids.index(item.id) }

      if @requested_items.size < @requested_item_ids.size
        difference = @requested_item_ids.size - @requested_items.size
        flash[:warning] = "#{helpers.pluralize(difference, "item")} #{"is".pluralize(difference)}
                           no longer available and have been removed from your requests."

        found_ids = @requested_items.map(&:id)
        Rails.logger.debug "Could not find items with ids #{@requested_item_ids - found_ids}"
        @requested_item_ids = session[:requested_item_ids] = found_ids
      end
    end

    def set_page_title
      @page_title = "Hold Request"
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

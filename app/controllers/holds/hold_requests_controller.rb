module Holds
  class HoldRequestsController < BaseController
    def new
      activate_step(:submit)
      @hold_request = HoldRequest.new
      @hold_slots = fetch_hold_slots
    end

    def create
      @hold_request = HoldRequest.new(hold_request_params)
      @hold_request.hold_request_items = @requested_items.map { |item|
        HoldRequestItem.new(item_id: item.id)
      }
      if @hold_request.save
        MemberMailer.with(hold_request: @hold_request).hold_confirmation.deliver_later
        session.delete(:requested_item_ids)
        redirect_to holds_confirmation_path(@hold_request.to_sgid)
      else
        @hold_slots = fetch_hold_slots
        activate_step(:submit)
        render :new, status: 422
      end
    end

    private

    def hold_request_params
      params.require(:hold_request).permit(:notes, :email, :postal_code, :event_id)
    end

    def fetch_hold_slots
      if ENV.fetch("FETCH_HOLD_SLOTS", false)
        slots = GoogleCalendar.new(calendar_id: ENV.fetch("HOLD_SLOTS_GOOGLE_CALENDAR_ID")).upcoming_events(
          Time.current, 3.weeks.since
        )
        Event.update_events(slots.value)
        slots.value
      else
        Event.upcoming
      end
    end
  end
end

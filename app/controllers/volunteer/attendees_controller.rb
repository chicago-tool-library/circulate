module Volunteer
  class AttendeesController < BaseController
    include ShiftsHelper
    include Calendaring

    def create
      @event = Event.volunteer_shifts.find(params[:event_id])
      if signed_in_via_google?
        event_signup(@event.calendar_event_id)
      else
        # store requested event id for later reference
        session[:event_id] = params[:event_id]
        render html: post_redirect("/auth/google_oauth2")
      end
    end

    def destroy
      if signed_in_via_google?
        @event = Event.volunteer_shifts.find(params[:id])
        event_remove_signup(@event.calendar_event_id)
      else
        redirect_to volunteer_shifts_url, error: "You must be logged in", status: :see_other
      end
    end

    private

    def post_redirect(path)
      <<~HTML.html_safe
        <form id="redirect" action="#{helpers.send(:h, path)}" method="post">
          <input name="authenticity_token" value="#{form_authenticity_token}" type="hidden">
        </form>
        <script>
          document.getElementById("redirect").submit();
        </script>
      HTML
    end

    def google_calendar_id
      ::Event.volunteer_shift_calendar_id
    end
  end
end

module Volunteer
  class ShiftsController < BaseController
    include ShiftsHelper
    include Calendaring

    def index
      load_upcoming_events
      @attendee = Attendee.new(email: session[:email], name: session[:name])
    end

    def calendar
      index
      @month_calendar = Volunteer::MonthCalendar.new(@events)
    end

    def new
      result = google_calendar.fetch_events(params[:event_ids])
      if result.success?
        @shift = Volunteer::Shift.new(result.value)
      else
        redirect_to volunteer_shifts_url, error: "That event was not found"
      end
    end

    def create
      if signed_in_via_google?
        event_signup(params[:event_id])
      else
        # store requested event id for later reference
        session[:event_id] = params[:event_id]
        render html: post_redirect("/auth/google_oauth2")
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
  end
end

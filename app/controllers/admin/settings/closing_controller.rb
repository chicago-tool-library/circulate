class Admin::Settings::ClosingController < Admin::BaseController
  before_action :require_admin

  def index
    @form = ExtendHoldsForm.new
    @dates = Hold.next_waiting_hold_dates
  end

  def extend_holds
    @form = ExtendHoldsForm.new(form_params)
    if @form.valid?
      # Convert naive date into an ActiveSupport::TimeWithZone in the correct timezone
      end_of_day = @form.date.in_time_zone(Time.zone).end_of_day
      Hold.extend_started_holds_until(end_of_day)

      redirect_to admin_settings_closing_path, success: "Started holds have been updated."
    else
      @dates = Hold.next_waiting_hold_dates
      render :index
    end
  end

  private

  def form_params
    params.require(:extend_holds_form).permit(:date)
  end
end

# frozen_string_literal: true

module LoansHelper
  def undo_button(loan)
    name, method, path, params = if loan.ended?
      if loan.item.borrow_policy.consumable?
        ["loan", :delete, admin_loan_path(loan)]
      else
        ["return", :patch, admin_loan_path(loan), { loan: { ended_at: nil } }]
      end
    elsif loan.renewal?
      ["renewal", :delete, admin_renewal_path(loan)]
    else
      ["loan", :delete, admin_loan_path(loan)]
    end
    button_to path, method: method, class: "btn btn-sm", remote: true, params: params do
      feather_icon("x") + "Undo #{name}"
    end
  end

  def humanize_due_date(loan)
    if loan.due_at.to_date == Time.zone.today
      "today"
    elsif loan.due_at.to_date == Time.zone.tomorrow
      "tomorrow"
    else
      loan.due_at.strftime("%a %m/%d")
    end
  end

  def humanize_date(date)
    if date == Time.zone.today
      "today"
    elsif date == Time.zone.tomorrow
      "tomorrow"
    else
      date.strftime("%A, %B %-d")
    end
  end

  def render_loan_status(loan)
    appointment_time = loan_pickup_status(loan)
    loan.status.capitalize + appointment_time
  end

  def loan_pickup_status(loan)
    appointment = loan.upcoming_appointment
    if appointment
      "Scheduled for return at #{format_date(appointment.starts_at)}, #{appointment_time(appointment)}"
    else
      ""
    end
  end

  def next_due_date(loans)
    humanize_date(loans.map(&:due_at).min)
  end

  private
    def format_date(date)
      date.strftime("%a, %-m/%-d")
    end

    def format_time_range(starts_at, ends_at)
      "#{starts_at.strftime("%l%P")}–#{ends_at.strftime("%l%P")}"
    end
end

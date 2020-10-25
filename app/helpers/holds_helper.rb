module HoldsHelper
  def hold_date(event)
    event.date.strftime("%A, %B %-d, between ") + event.times.sub("-", "&")
  end

  def hold_slot_options(slots)
    grouped_slots = slots.group_by(&:date).map { |date, slots|
      [date.strftime("%B %-d, %Y"), slots.map { |s| [hold_date(s), s.id] }]
    }
    grouped_options_for_select(grouped_slots)
  end

  def render_hold_items(items, &block)
    block ||= proc {}
    render layout: "holds/items", locals: {items: items}, &block
  end

  def render_hold_status(hold)
    previous_holds_count = hold.previous_active_holds.count
    appointment = hold.upcoming_appointment

    if appointment
      "Scheduled for pick-up at #{format_date(appointment.starts_at)} " +
      format_time_range(appointment.starts_at, appointment.ends_at)
    elsif hold.ready_for_pickup?
      "Ready for pickup. Schedule by #{format_date(hold.created_at + 7.days)}"
    else
      "##{previous_holds_count} on wait list"
    end
  end

  private

  def format_date(date)
    date.strftime("%a, %-m/%-d")
  end

  def format_time_range(starts_at, ends_at)
    "#{starts_at.strftime('%l%P')} - #{ends_at.strftime('%l%P')}"
  end
end

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
      "Scheduled for pick-up at #{format_date(appointment.starts_at)}, " +
        appointment_time(appointment)
    elsif hold.ready_for_pickup?
      if hold.expires_at
        "Ready for pickup. Schedule by #{format_date(hold.expires_at)}"
      else
        "Ready for pickup."
      end
    else
      "##{previous_holds_count + 1} on wait list"
    end
  end

  def render_remove_link(hold)
    unless hold.appointments.present?
      link_to("Remove", account_hold_path(hold), method: :delete, data: {confirm: "Are you sure you want to remove this hold?"})
    end
  end

  def place_in_line_for(hold)
    Item.find(hold.item.id).holds.active.index(hold) + 1
  end

  private

  def format_date(date)
    date.strftime("%a, %-m/%-d")
  end
end

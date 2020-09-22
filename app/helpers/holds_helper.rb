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

  def render_place_in_queue(hold)
    last_hold = hold.previous_active_holds.last
    count = hold.previous_active_holds.count

    if count == 0
      pickup_deadline = hold.created_at + 7.days
      formatted_date = pickup_deadline.strftime("%a %-d/%y")
      "Ready for pickup. Schedule by #{formatted_date}."
    elsif last_hold
      "##{count} on wait list."
    end
  end
end

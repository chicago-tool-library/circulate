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
    prev_hold = hold.previous_active_holds.last
    count = hold.previous_active_holds.count

    if prev_hold.present? && count == 0
      "Ready for pickup. Schedule by #{format_date(prev_hold.loan.ended_at + 7.days)}"
    elsif count == 0
      "Ready for pickup. Schedule by #{format_date(hold.created_at + 7.days)}"
    else
      "##{count} on wait list"
    end
  end

  def place_in_line_for(hold)
    Item.find(hold.item.id).holds.active.index(hold) + 1
  end

  private

  def format_date(date)
    date.strftime("%a, %-m/%-d/%Y")
  end
end

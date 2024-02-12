class ItemPool < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :reservable_items
  has_many :date_holds

  ## Return a Hash of date => reserved quantity for the provided date range
  def reserved_by_date(starts, ends, ignored_reservation_id: nil)
    query = self.class
      .joins(date_holds: :reservation)
      .joins(self.class.sanitize_sql_array(["JOIN generate_series(?, ?, interval '1 day') d(the_day) ON the_day BETWEEN reservations.started_at AND reservations.ended_at", starts, ends]))
      .where("item_pools.id = ?", id)
      .group("the_day")
      .order("the_day ASC")

    if ignored_reservation_id
      query = query.where.not(reservations: {id: ignored_reservation_id})
    end

    values = {}
    query.pluck("the_day", Arel.sql("COALESCE(SUM(date_holds.quantity), 0)")).each do |day, reserved|
      values[day.to_date] = reserved
    end

    starts.to_date.upto(ends.to_date).each_with_object({}) do |date, hash|
      hash[date] = values[date] || 0
    end
  end

  # Return how many items are available for the entire duration between starts and ends.
  def max_available_between(starts, ends, ignored_reservation_id: nil)
    total_items = reservable_items.count

    query = self.class
      .joins(date_holds: :reservation)
      .joins(self.class.sanitize_sql_array(["JOIN generate_series(?, ?, interval '1 day') d(the_day) ON the_day BETWEEN reservations.started_at AND reservations.ended_at", starts, ends]))
      .where("item_pools.id = ?", id)
      .group("the_day")

    if ignored_reservation_id
      query = query.where.not(reservations: {id: ignored_reservation_id})
    end

    held_each_day = query.pluck(Arel.sql("COALESCE(SUM(date_holds.quantity), 0)"))

    if held_each_day.empty?
      total_items
    else
      total_items - held_each_day.max
    end
  end
end

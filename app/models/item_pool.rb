class ItemPool < ApplicationRecord
  include ItemCategorization

  has_rich_text :description

  belongs_to :creator, class_name: "User"
  belongs_to :reservation_policy, optional: true
  has_many :reservable_items
  has_many :reservation_holds

  validates :name, presence: true
  validate :unnumbered_has_no_items
  validates :max_reservable_percentage_points, numericality: {only_integer: true, allow_nil: true, in: 1..100}

  scope :uniquely_numbered, -> { where(uniquely_numbered: true) }
  scope :not_uniquely_numbered, -> { where(uniquely_numbered: false) }

  acts_as_tenant :library

  def max_reservable_percentage_points=(value)
    self.max_reservable_percent = value.present? ? value.to_f / 100 : nil
  end

  def max_reservable_percentage_points
    (max_reservable_percent * 100).floor if max_reservable_percent
  end

  # Return how many total items are available for borrowing. If per_reservation is true, then
  # the number returned is how many a single reservation can claim.
  def max_reservable_quantity(per_reservation: false)
    total_items = if uniquely_numbered
      reservable_items_count
    else
      unnumbered_count
    end

    if per_reservation && max_reservable_percent.present?
      (total_items * max_reservable_percent).floor
    else
      total_items
    end
  end

  # Return a Hash of date => reserved quantity for every day in the range provided
  def reserved_by_date(starts, ends, ignored_reservation_id: nil)
    totals_by_day = sum_reservations_by_day(starts, ends, ignored_reservation_id:)
    starts.to_date.upto(ends.to_date).each_with_object({}) do |date, hash|
      hash[date] = totals_by_day[date] || 0
    end
  end

  # Return the maximum number of items that are available for reservation for the entire duration
  # between starts and ends.
  def max_available_between(starts, ends, ignored_reservation_id: nil, per_reservation: false)
    total_items = max_reservable_quantity(per_reservation:)

    totals_by_day = sum_reservations_by_day(starts, ends, ignored_reservation_id:)

    if totals_by_day.empty?
      total_items
    else
      total_items - totals_by_day.values.max
    end
  end

  private

  # Return a Hash of date => total reservations for the given range.
  # If ignored_reservation_id is provided, it will not be included in the totals.
  def sum_reservations_by_day(starts, ends, ignored_reservation_id: nil)
    query = self.class
      .joins(reservation_holds: :reservation)
      .joins(self.class.sanitize_sql_array(["JOIN generate_series(?, ?, interval '1 day') d(the_day) ON the_day BETWEEN reservations.started_at AND reservations.ended_at", starts, ends]))
      .where(item_pools: {id: id})
      .group("the_day")
      .order("the_day ASC")

    if ignored_reservation_id
      query = query.where.not(reservations: {id: ignored_reservation_id})
    end

    {}.tap do |hash|
      query.pluck("the_day", Arel.sql("COALESCE(SUM(reservation_holds.quantity), 0)")).each do |day, reserved|
        hash[day.to_date] = reserved
      end
    end
  end

  def unnumbered_has_no_items
    if !uniquely_numbered && reservable_items.size > 0
      errors.add(:uniquely_numbered, "must be uniquely numbered with attached reservable items")
    end
  end
end

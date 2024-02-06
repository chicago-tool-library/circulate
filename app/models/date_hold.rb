class DateHold < ApplicationRecord
  belongs_to :reservation
  belongs_to :reservable_item

  scope :overlapping, ->(starts, ends) { joins(:reservation).where("tsrange(?, ?) && tsrange(reservations.started_at, reservations.ended_at)", starts, ends) }
end

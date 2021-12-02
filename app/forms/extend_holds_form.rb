class ExtendHoldsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date

  # Only to allow for the current time to be stubbed in tests
  attr_accessor :now

  validate :date_in_near_future

  def earliest_valid_date
    (now || Date.current).tomorrow
  end

  def latest_valid_date
    earliest_valid_date + 30.days
  end

  private

  def date_in_near_future
    unless (earliest_valid_date..latest_valid_date).cover?(date)
      errors.add(:date, "must be a date within the next month")
    end
  end
end

# frozen_string_literal: true

require "test_helper"

class ExtendHoldsFormTest < ActiveSupport::TestCase
  test "invalid when date is blank" do
    form = ExtendHoldsForm.new
    assert_not form.valid?
    assert_equal ["must be a date within the next month"], form.errors[:date]
  end

  test "invalid with invalid date" do
    form = ExtendHoldsForm.new(date: "invalid date")
    assert_not form.valid?
    assert_equal ["must be a date within the next month"], form.errors[:date]
  end

  test "invalid with past date" do
    form = ExtendHoldsForm.new(date: 1.day.ago.to_date.iso8601)
    assert_not form.valid?
    assert_equal ["must be a date within the next month"], form.errors[:date]
  end

  test "invalid with far future date" do
    form = ExtendHoldsForm.new(date: 32.days.since.to_date.iso8601)
    assert_not form.valid?
    assert_equal ["must be a date within the next month"], form.errors[:date]
  end

  test "valid with valid date" do
    form = ExtendHoldsForm.new(date: "2021-10-08")
    form.now = Date.new(2021, 10, 1)
    assert form.valid?
  end
end

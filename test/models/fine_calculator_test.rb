# frozen_string_literal: true

require "test_helper"

class FineCalculatorTest < ActiveSupport::TestCase
  setup do
    @june_first = Time.zone.parse("2019-06-01").end_of_day
    @fine = Money.new(100)
  end

  test "returned on time" do
    amount = FineCalculator.new.amount(fine: @fine, period: 1, due_at: @june_first, returned_at: @june_first - 1.second)
    assert_equal 0, amount
  end

  test "returned within the fine_period" do
    amount = FineCalculator.new.amount(fine: @fine, period: 1, due_at: @june_first, returned_at: @june_first + 1.second)
    assert_equal Money.new(100), amount
  end

  test "returned exactly one day late" do
    amount = FineCalculator.new.amount(fine: @fine, period: 1, due_at: @june_first, returned_at: @june_first + 1.day)
    assert_equal Money.new(100), amount
  end

  test "returned more than a single period late" do
    amount = FineCalculator.new.amount(fine: @fine, period: 1, due_at: @june_first, returned_at: @june_first + 4.days)
    assert_equal Money.new(400), amount
  end

  test "returned two periods late, 7-day periods" do
    amount = FineCalculator.new.amount(fine: @fine, period: 7, due_at: @june_first, returned_at: @june_first + 14.days)
    assert_equal Money.new(200), amount
  end

  test "returned more than a two periods late, 7-day periods" do
    amount = FineCalculator.new.amount(fine: @fine, period: 7, due_at: @june_first, returned_at: @june_first + 14.days + 1.second)
    assert_equal Money.new(300), amount
  end
end

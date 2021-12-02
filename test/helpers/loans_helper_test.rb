require "test_helper"

class LoansHelperTest < ActionView::TestCase
  test "humanize_due_date returns due date formatted as '%a %m/%d' when due date is after tomorrow" do
    @loan = build(:loan, due_at: 12.days.from_now)

    assert_equal @loan.due_at.strftime("%a %m/%d"), humanize_due_date(@loan)
  end

  test "humanize_due_date returns tomorrow when due date is tomorrow" do
    @loan = build(:loan, due_at: Time.zone.today + 1.day)
    assert_equal "tomorrow", humanize_due_date(@loan)
  end

  test "humanize_due_date returns today when due date is today" do
    @loan = build(:loan, due_at: Time.zone.today)

    assert_equal "today", humanize_due_date(@loan)
  end
end

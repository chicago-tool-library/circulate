require 'test_helper'

class LoansHelperTest < ActionView::TestCase
  test "humanize_due_date returns due date formatted as '%a %m/%d' when due date is more than a week away" do
    @loan = build(:loan)

    assert_equal @loan.due_at.strftime("%a %m/%d"), humanize_due_date(@loan)
  end
end

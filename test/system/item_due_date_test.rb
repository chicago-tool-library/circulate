require "application_system_test_case"

class ItemDueDateTest < ApplicationSystemTestCase
  def setup
    @due_soon = create(:item, name: "Due Soon Drill")
    create(:loan, :checked_out, :exclusive, item: @due_soon, due_at: 3.days.from_now)

    @on_hold = create(:item, name: "Spoken For Sander")
    create(:loan, :checked_out, :exclusive, item: @on_hold, due_at: 3.days.from_now)
    create(:hold, :active, item: @on_hold)

    @overdue = create(:item, name: "Tardy Tablesaw")
    create(:overdue_loan, item: @overdue)
  end

  test "the item list shows the days until a checked out item is due" do
    visit items_url

    within("#item-#{@due_soon.id}") do
      assert_content "Checked Out"
      assert_content "Due in 3 days"
    end
  end

  test "the item list hides the countdown for items with holds or that are overdue" do
    visit items_url

    within("#item-#{@on_hold.id}") do
      assert_content "1 hold"
      refute_content "Due in"
    end

    within("#item-#{@overdue.id}") do
      assert_content "Overdue"
      refute_content "Due in"
    end
  end

  test "the item show page shows the days until the item is due" do
    visit item_url(@due_soon)

    assert_content "Due in 3 days"
  end

  test "the item show page hides the countdown for items with holds or that are overdue" do
    visit item_url(@on_hold)
    refute_content "Due in"

    visit item_url(@overdue)
    refute_content "Due in"
  end
end

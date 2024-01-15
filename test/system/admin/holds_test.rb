require "application_system_test_case"

class HoldsTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "pending member can reserve items" do
    @member = create(:member)
    @item = create(:item)

    visit admin_member_holds_url(@member)

    assert_content "need to be verified"

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Hold"

    within "#current-holds" do
      assert_text @item.name
    end
  end

  test "member without membership can reserve items" do
    @member = create(:verified_member)
    @item = create(:item)

    visit admin_member_url(@member)

    assert_content "needs to start a membership"

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Hold"

    within "#current-holds" do
      assert_text @item.name
    end
  end

  test "places item on hold" do
    @item = create(:item)
    @member = create(:verified_member_with_membership)

    visit admin_member_holds_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Hold"

    within "#current-holds" do
      assert_text @item.name
      click_on "Cancel"
    end

    refute_selector "#current-holds"
    refute_text @item.name
  end

  test "places a checked out item on hold" do
    @loan = create(:loan)
    @item = @loan.item
    @member = create(:verified_member_with_membership)

    visit admin_member_holds_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Hold"

    within "#current-holds" do
      assert_text @item.name
      click_on "Cancel"
    end

    refute_selector "#current-holds"
    refute_text @item.name
  end

  test "shows if an item is on hold during checkout" do
    @item = create(:item)
    @hold = create(:hold, item: @item, creator: @user)
    @member = create(:verified_member_with_membership)

    visit admin_member_holds_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      click_on "on hold by 1 person"
    end

    assert_text @member.preferred_name
  end

  test "can't reserve an item for member with overdue item" do
    @overdue_item = create(:item)
    @member = create(:verified_member_with_membership)

    create(:loan, item: @overdue_item, member: @member, due_at: 1.week.ago)

    visit admin_member_holds_url(@member)

    assert_text "Overdue items must be returned"

    within ".member-lookup-items" do
      refute_selector "input"
    end
  end

  test "lends all holds" do
    @member = create(:verified_member_with_membership)
    @item = create(:item)
    @hold = create(:hold, member: @member, item: @item, creator: @user)

    visit admin_member_holds_url(@member)

    within "#current-holds" do
      assert_text @item.name
    end

    click_on "Lend All Holds"

    within "#current-loans" do
      assert_text @item.name
    end

    click_on "Holds"

    refute_selector "#current-holds"
    refute_text @item.name
  end

  test "viewing an item's holds" do
    @item = create(:item)
    @active_hold = create(:hold, item: @item)
    @inactive_hold = create(:ended_hold, item: @item)

    visit admin_item_holds_path(@item)
    find("[data-hold-id='#{@active_hold.id}']")

    click_on "Ended"
    find("[data-hold-id='#{@inactive_hold.id}']")
  end

  test "reordering holds" do
    @item = create(:item)
    @holds = 4.times.map { create(:hold, item: @item) }

    visit admin_item_holds_path(@item)

    @handles = all(".drag-handle")
    assert_equal 4, @handles.size
    hold_ids = all(".item-holds-table tr[data-hold-id]").map { |row| row["data-hold-id"] }

    # Make the first hold the last
    @handles.first.drag_to @handles.last
    # Wait for the update to complete
    assert_no_selector "div[data-controller='hold-order'][aria-busy='true']"

    # make sure it worked
    reordered_hold_ids = all(".item-holds-table tr[data-hold-id]").map { |row| row["data-hold-id"] }
    expected_hold_ids = hold_ids[1..] + [hold_ids[0]]
    assert_equal expected_hold_ids, reordered_hold_ids

    # reload the page and make sure it was persisted
    visit admin_item_holds_path(@item)
    reloaded_hold_ids = all(".item-holds-table tr[data-hold-id]").map { |row| row["data-hold-id"] }
    assert_equal expected_hold_ids, reloaded_hold_ids
  end
end

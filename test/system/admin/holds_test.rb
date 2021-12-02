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
end

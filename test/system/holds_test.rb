require "application_system_test_case"

class HoldsTest < ApplicationSystemTestCase
  def list_item_containing(text)
    find("li", text: text)
  end

  setup do
    ActionMailer::Base.deliveries.clear
    @member = create(:verified_member_with_membership)
  end

  test "member can place a hold" do
    login_as @member.user

    @item = create(:item)

    visit item_url(@item)
    click_button "Place a hold"

    assert_selector "button[disabled]", text: "Place a hold"
    assert_text "Hold placed."
  end

  test "member can't place a hold on an item in maintenance" do
    login_as @member.user

    @item = create(:item, status: :maintenance)

    visit item_url(@item)

    refute_selector 'input[value="Place a hold"]'
  end

  test "member with an unconfirmed email can't place a hold on an item" do
    member = create(:member, user: create(:user, :unconfirmed))
    login_as member.user

    item = create(:item)

    visit item_url(item)

    assert_text "Confirm your email address before placing this item on hold"
  end

  test "member can place a hold multiple times when the borrow policy allows it" do
    login_as @member.user

    @item = create(:uncounted_item)

    visit item_url(@item)

    click_button "Place a hold"
    assert_text "You currently have 1 hold placed."

    click_button "Place a hold"
    assert_text "You currently have 2 holds placed."
  end

  test "puts checked out items on hold" do
    login_as @member.user

    @item = create(:item)
    create(:loan, item: @item)
    @popular_item = create(:item)
    create(:loan, item: @popular_item)
    create(:hold, item: @popular_item)

    visit item_url(@item)
    click_button "Place a hold"

    visit item_url(@popular_item)
    click_button "Place a hold"

    assert_selector "button[disabled]", text: "Place a hold"
    assert_text "Hold placed."

    visit account_holds_path
    within(list_item_containing(@item.complete_number)) { assert_text "#1 on wait list" }
    within(list_item_containing(@popular_item.complete_number)) { assert_text "#2 on wait list" }
  end

  test "member with next hold is notified when an item is returned" do
    @admin = create(:admin_user)

    @item = create(:item)
    @loan = create(:loan, item: @item)
    @second_hold = create(:hold, item: @item, member: @member, position: 30)
    @first_hold = create(:hold, item: @item, position: 29)

    login_as @admin

    visit admin_member_url(@loan.member)

    within "#current-loans" do
      assert_text @item.name
      click_on "Return"
    end

    refute_selector "#current-loans", wait: slow_op_wait_time

    Hold.start_waiting_holds do |hold|
      assert_equal @first_hold, hold
    end

    @first_hold.reload
    assert @first_hold.started?
  end

  test "holds are shown only in hold history after two weeks" do
    login_as @member.user

    @item = create(:item)

    travel_to 15.days.ago do
      create(:started_hold, member: @member, item: @item)
    end

    visit account_holds_path
    refute_text @item.complete_number
    refute_text @item.name

    visit history_account_holds_path
    assert_text @item.complete_number
    assert_text @item.name
  end

  test "hold history only shows inactive holds" do
    login_as @member.user

    @started_hold_item = create(:item)
    @expired_hold_item = create(:item)
    @ended_hold_item = create(:item)

    @started_hold = create(:started_hold, member: @member, item: @started_hold_item)
    @expired_hold = create(:expired_hold, member: @member, item: @expired_hold_item)
    @ended_hold = create(:ended_hold, member: @member, item: @ended_hold_item)

    visit history_account_holds_path
    refute_text @started_hold.item.name
    refute_text @started_hold.item.complete_number
    assert_text @expired_hold.item.name
    assert_text @expired_hold.item.complete_number
    assert_text @ended_hold.item.name
    assert_text @ended_hold.item.complete_number
  end
end

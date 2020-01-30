require "application_system_test_case"

class CheckInCheckOutTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "pending member can't checkout items" do
    @member = create(:member)

    visit admin_member_url(@member)

    assert_content "need to be verified"
    refute_selector ".member-checkout-items"
  end

  test "member without membership can't checkout items" do
    @member = create(:verified_member)

    visit admin_member_url(@member)

    assert_content "needs to start a membership"
    refute_selector ".member-checkout-items"
  end

  test "checks out items to member" do
    @item = create(:item)
    @member = create(:verified_member_with_membership)

    visit admin_member_url(@member)

    fill_in :admin_check_out_item_number, with: @item.number
    click_on "Lookup"

    within ".member-checkout-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Lend Item"

    within ".member-active-loans" do
      assert_text @item.name
    end
  end

  test "returns loaned item" do
    @item = create(:item)
    @member = create(:verified_member_with_membership)
    create(:loan, item: @item, member: @member)

    visit admin_member_url(@member)

    within ".member-active-loans" do
      assert_text @item.name
      click_on "Return"
    end

    refute_selector ".member-active-loans"
  end

  test "returns loaned overdue item" do
    @item = create(:item)
    @member = create(:verified_member_with_membership)
    create(:loan, item: @item, member: @member, due_at: 2.weeks.ago)

    visit admin_member_url(@member)

    within ".member-active-loans" do
      assert_text @item.name
      click_on "Return"
    end

    refute_selector ".member-active-loans"

    assert_content "$-15.00"
  end

  test "renews item" do
    Time.use_zone "America/Chicago" do
      sunday = Time.new(2020, 1, 26).end_of_day
      @item = create(:item)
      @member = create(:verified_member_with_membership)
      create(:loan, item: @item, member: @member, due_at: sunday, created_at: sunday - 7.days)

      saturday = Time.new(2020, 1, 25, 12, 30)

      travel_to saturday do
        visit admin_member_url(@member)

        within ".member-active-loans" do
          assert_text @item.name
          assert_text "Due Sunday, January 26"
          click_on "Renew"
        end

        within ".member-active-loans" do
          refute_text "Due Sunday, January 27"
          assert_text "Due Sunday, February 2"
          assert_text @item.name
        end
      end
    end
  end

  test "can't renew item with max renewals" do
    Time.use_zone "America/Chicago" do
      sunday = Time.new(2020, 1, 26).end_of_day
      borrow_policy = create(:borrow_policy, renewal_limit: 0)
      @item = create(:item, borrow_policy: borrow_policy)
      @member = create(:verified_member_with_membership)
      create(:loan, item: @item, member: @member, due_at: sunday, created_at: sunday - 7.days)

      saturday = Time.new(2020, 1, 25, 12, 30)

      travel_to saturday do
        visit admin_member_url(@member)

        within ".member-active-loans" do
          assert_text @item.name
          assert_text "Due Sunday, January 26"
          assert_selector "button:disabled", text: "Renew"
        end
      end
    end
  end
end

require "test_helper"

# Checking an item out has to keep holds and pickup appointments in step with
# where the item actually is.
module Admin
  class LoanEndsHoldsTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    setup do
      @item = create(:item)
      sign_in create(:admin_user)
    end

    # Staff check the item out from the member page instead of the member's
    # pickup appointment.
    test "checking an item out to a member ends that member's hold on it" do
      member = create(:verified_member)
      hold = create(:started_hold, member: member, item: @item)
      returning = create(:loan, member: member)
      appointment = create(:appointment, member: member, holds: [hold], loans: [returning], starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours)

      post admin_loans_url, params: {loan: {item_id: @item.id, member_id: member.id}}

      hold.reload
      assert hold.ended?, "hold is still active after the item was checked out to the same member"
      assert_equal Loan.last, hold.loan
      assert_empty appointment.reload.holds, "picked-up hold is still on the later appointment"
    end

    test "checking an item out to a different member is refused while it's ready for someone else" do
      waiting_member = create(:verified_member)
      hold = create(:started_hold, member: waiting_member, item: @item)
      create(:appointment, member: waiting_member, holds: [hold], starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours)
      other_member = create(:verified_member)

      assert_no_difference("Loan.count", "item was lent out from under a scheduled pickup") do
        post admin_loans_url, params: {loan: {item_id: @item.id, member_id: other_member.id}}
      end
      assert_match "ready for pickup by member ##{waiting_member.number}", flash[:checkout_error]
    end

    test "a walk-in's own hold further back in line doesn't get them past a ready hold" do
      first = create(:verified_member)
      ready = create(:started_hold, member: first, item: @item)
      walk_in = create(:verified_member)
      create(:hold, member: walk_in, item: @item)

      assert_no_difference("Loan.count") do
        post admin_loans_url, params: {loan: {item_id: @item.id, member_id: walk_in.id}}
      end
      assert ready.reload.started?
    end

    test "an admin lending over a ready hold keeps the line in order and leaves notifying the member to staff" do
      first = create(:verified_member)
      ready = create(:started_hold, member: first, item: @item)
      second = create(:hold, member: create(:verified_member), item: @item)
      appointment = create(:appointment, member: first, holds: [ready], starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours)
      walk_in = create(:verified_member)

      assert_no_emails do
        assert_no_enqueued_jobs(except: StartWaitingHoldsJob) do
          post admin_loans_url, params: {loan: {item_id: @item.id, member_id: walk_in.id}, over_ready_hold: "1"}
        end
      end
      assert_match "They haven't been notified", flash[:warning]
      assert_match "##{first.number}", flash[:warning]
      assert_match "was cancelled", flash[:warning]

      assert_equal walk_in, @item.reload.checked_out_exclusive_loan.member
      ready.reload
      assert ready.active?
      refute ready.started?, "bumped hold should be waiting again"
      assert_nil ready.expires_at
      assert_equal [ready, second], Hold.active.where(item: @item).ordered_by_position.to_a, "line order changed"
      refute Appointment.exists?(appointment.id), "appointment for only the bumped item should be cancelled"
    end

    test "lending over a ready hold to a walk-in who is also in line uses their hold" do
      first = create(:verified_member)
      ready = create(:started_hold, member: first, item: @item)
      walk_in = create(:verified_member)
      own = create(:hold, member: walk_in, item: @item)

      post admin_loans_url, params: {loan: {item_id: @item.id, member_id: walk_in.id}, over_ready_hold: "1"}

      assert own.reload.ended?
      assert_equal own.loan, @item.reload.checked_out_exclusive_loan
      assert ready.reload.active?
    end

    # The member picks the item up a day early from their holds page.
    test "lending a hold early takes it off the member's later appointment" do
      member = create(:verified_member)
      hold = create(:started_hold, member: member, item: @item)
      returning = create(:loan, member: member)
      appointment = create(:appointment, member: member, holds: [hold], loans: [returning], starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours)

      post lend_admin_member_hold_url(member, hold)

      assert hold.reload.ended?
      assert_empty appointment.reload.holds, "picked-up hold is still on tomorrow's appointment"
      assert_equal [returning], appointment.loans
    end

    test "lending a hold early cancels a later appointment that has nothing else on it" do
      member = create(:verified_member)
      hold = create(:started_hold, member: member, item: @item)
      appointment = create(:appointment, member: member, holds: [hold], starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours)

      post lend_admin_member_hold_url(member, hold)

      refute Appointment.exists?(appointment.id)
    end

    test "checking out holds during today's appointment leaves the appointment alone" do
      member = create(:verified_member)
      hold = create(:started_hold, member: member, item: @item)
      appointment = create(:appointment, member: member, holds: [hold], starts_at: Time.current, ends_at: 1.hour.from_now)

      post admin_member_hold_loan_url(member)

      assert hold.reload.ended?
      assert_equal [hold], appointment.reload.holds
    end

    test "ending a hold from the item page takes it off the member's appointment" do
      member = create(:verified_member)
      hold = create(:started_hold, member: member, item: @item)
      returning = create(:loan, member: member)
      appointment = create(:appointment, member: member, holds: [hold], loans: [returning], starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours)

      patch admin_item_hold_remove_url(@item, hold_id: hold.id)

      assert hold.reload.ended?
      assert_empty appointment.reload.holds
    end

    test "the checkout preview warns when the item is ready for someone else" do
      first = create(:verified_member)
      create(:started_hold, member: first, item: @item)
      walk_in = create(:verified_member_with_membership)

      get admin_member_lookup_url(walk_in, admin_lookup: {item_number: @item.number.to_s})

      assert_response :success
      assert_match "Only lend it anyway in an emergency", response.body
      assert_select "button[name=over_ready_hold][value='1']", text: /Lend anyway/
    end

    test "staff without the admin role can't lend over a ready hold" do
      sign_in create(:staff_user)
      first = create(:verified_member)
      ready = create(:started_hold, member: first, item: @item)
      walk_in = create(:verified_member_with_membership)

      get admin_member_lookup_url(walk_in, admin_lookup: {item_number: @item.number.to_s})
      assert_match "DO NOT lend it out to another member", response.body
      assert_select "button[name=over_ready_hold]", count: 0

      assert_no_difference("Loan.count") do
        post admin_loans_url, params: {loan: {item_id: @item.id, member_id: walk_in.id}, over_ready_hold: "1"}
      end
      assert ready.reload.started?
    end
  end
end

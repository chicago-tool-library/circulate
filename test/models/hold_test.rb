# frozen_string_literal: true

require "test_helper"

class HoldTest < ActiveSupport::TestCase
  test "#upcoming_appointment should call its member.upcoming_appointment_of with itself" do
    member_double = Minitest::Mock.new
    hold = create(:hold)
    hold.stub :member, member_double do
      member_double.expect(:upcoming_appointment_of, nil, [hold])
      hold.upcoming_appointment
    end
  end

  test "new hold" do
    hold = create(:hold, ended_at: nil, started_at: nil)

    assert hold.active?
    assert_not hold.inactive?
    assert_not hold.ended?
    assert_not hold.expired?
    assert_not hold.started?

    assert Hold.active.find_by(id: hold)
    assert_not Hold.inactive.find_by(id: hold)
    assert_not Hold.ended.find_by(id: hold)
    assert_not Hold.expired.find_by(id: hold)
    assert_not Hold.started.find_by(id: hold)
  end

  test "started hold" do
    hold = create(:started_hold)

    assert hold.active?
    assert_not hold.inactive?
    assert_not hold.ended?
    assert_not hold.expired?
    assert hold.started?

    assert Hold.active.find_by(id: hold)
    assert_not Hold.inactive.find_by(id: hold)
    assert_not Hold.ended.find_by(id: hold)
    assert_not Hold.expired.find_by(id: hold)
    assert Hold.started.find_by(id: hold)
  end

  test "ended hold" do
    hold = create(:hold, ended_at: 2.days.ago, started_at: 5.days.ago, expires_at: 3.days.since)

    assert_not hold.active?
    assert hold.inactive?
    assert hold.ended?
    assert_not hold.expired?
    assert hold.started?

    assert_not Hold.active.find_by(id: hold)
    assert Hold.inactive.find_by(id: hold)
    assert Hold.ended.find_by(id: hold)
    assert_not Hold.expired.find_by(id: hold)
    assert Hold.started.find_by(id: hold)
  end

  test "expired hold" do
    hold = create(:hold, ended_at: nil)
    hold.start!(15.days.ago)

    assert_not hold.active?
    assert hold.inactive?
    assert_not hold.ended?
    assert hold.expired?
    assert hold.started?

    assert_not Hold.active.find_by(id: hold)
    assert Hold.inactive.find_by(id: hold)
    assert_not Hold.ended.find_by(id: hold)
    assert Hold.expired.find_by(id: hold)
    assert Hold.started.find_by(id: hold)
  end

  test "doesn't expire until the end of the day" do
    hold_started = Date.new(2021, 5, 27, 16)
    hold = create(:hold, ended_at: nil)
    hold.start!(hold_started)

    travel_to (hold_started + Hold::HOLD_LENGTH).end_of_day do
      assert hold.active?
      assert_not hold.inactive?
      assert_not hold.ended?
      assert_not hold.expired?
      assert hold.started?

      assert Hold.active.find_by(id: hold)
      assert_not Hold.inactive.find_by(id: hold)
      assert_not Hold.ended.find_by(id: hold)
      assert_not Hold.expired.find_by(id: hold)
      assert Hold.started.find_by(id: hold)
    end
  end

  test "#start!" do
    hold = create(:hold)
    assert_not hold.started_at
    assert_not hold.expires_at

    hold.start!
    assert hold.started_at
    assert hold.expires_at
  end

  test "#ready_for_pickup? is true by default" do
    hold = create(:hold)

    assert hold.ready_for_pickup?
  end

  test "#ready_for_pickup? is false when an item is checked out" do
    hold = create(:hold)
    create(:loan, item: hold.item)

    hold.reload
    assert_not hold.ready_for_pickup?
  end

  test "#ready_for_pickup? is false when there is an earlier hold" do
    hold = create(:hold)
    second_hold = create(:hold, item: hold.item)

    assert_not second_hold.ready_for_pickup?
  end

  test "#ready_for_pickup? is true for uncounted items despite active loans" do
    item = create(:uncounted_item)

    hold = create(:hold, item:)
    create(:loan, item:)

    hold.reload
    assert hold.ready_for_pickup?
  end

  test "start_waiting_holds starts a hold" do
    create(:hold)

    started = assert_difference("Hold.started.count") {
      Hold.start_waiting_holds
    }
    assert_equal 1, started

    # should be safe to run again
    assert_no_difference("Hold.started.count") {
      Hold.start_waiting_holds
    }
  end

  test "start_waiting_holds starts multiple holds" do
    3.times do
      create(:hold)
    end

    started = assert_difference("Hold.started.count", 3) {
      Hold.start_waiting_holds
    }
    assert_equal 3, started
  end

  test "start_waiting_holds starts only the next hold for an item" do
    hammer = create(:item)
    create(:hold, item: hammer)
    create(:hold, item: hammer)

    started = assert_difference("Hold.started.count") {
      Hold.start_waiting_holds
    }
    assert_equal 1, started
  end

  test "does not start a hold when an item isn't available" do
    hammer = create(:item)
    create(:loan, item: hammer)
    create(:hold, item: hammer)

    started = assert_no_difference("Hold.started.count") {
      Hold.start_waiting_holds
    }
    assert_equal 0, started
  end

  test "does not start an already started hold" do
    hold = create(:started_hold)

    # pass in a time in the future to more easily detect if started_at
    # was modified
    started = Hold.start_waiting_holds(1.hour.since)
    assert_equal 0, started

    assert_in_delta hold.started_at, hold.reload.started_at, 1.second
  end

  test "does not start an ended hold" do
    hold = create(:ended_hold)
    hold.start!

    started = assert_no_difference("Hold.started.count") {
      Hold.start_waiting_holds
    }
    assert_equal 0, started
  end

  test "starts all of the holds for an uncounted item" do
    item = create(:uncounted_item)
    3.times do
      create(:hold, item:)
    end

    started = assert_difference("Hold.started.count", 3) {
      Hold.start_waiting_holds
    }
    assert_equal 3, started
  end

  test "starts the next hold when a previous one times out" do
    hammer = create(:item)
    hold1 = create(:hold, item: hammer)
    hold2 = create(:hold, item: hammer)

    assert_difference("Hold.started.count") do
      Hold.start_waiting_holds do |hold|
        assert_equal hold1, hold
      end
    end

    hold1.reload
    hold2.reload
    assert hold1.started?
    assert_not hold2.started?

    assert_difference("Hold.started.count") do
      Hold.start_waiting_holds(15.days.since) do |hold|
        assert_equal hold2, hold
      end
    end

    hold2.reload
    assert hold2.started?
  end

  test "handles a hold on a retired item" do
    hammer = create(:item)
    create(:hold, item: hammer)
    hammer.update!(status: "retired")

    assert_no_difference("Hold.started.count") do
      Hold.start_waiting_holds do |hold|
        fail "should not be called"
      end
    end
  end

  test "does not start a hold on an item in maintenance" do
    hammer = create(:item)
    create(:hold, item: hammer)
    hammer.update!(status: Item.statuses[:maintenance])

    assert_no_difference("Hold.started.count") do
      Hold.start_waiting_holds do |hold|
        fail "should not be called"
      end
    end
  end

  test "is ready for pickup if item is uncounted" do
    item = create(:uncounted_item)

    hold = create(:hold, item:)
    assert hold.ready_for_pickup?

    second_hold = create(:hold, item:)
    assert second_hold.ready_for_pickup?
  end

  test "can be put on hold if the item is active" do
    item = create(:item, status: :active)
    member = create(:verified_member_with_membership)

    hold = Hold.new(item:, member:, creator: member.user)
    assert hold.valid?
  end

  %i[pending retired maintenance].each do |status|
    test "can't be put on hold if the item is #{status}" do
      item = create(:item, status:)
      member = create(:verified_member_with_membership)

      hold = Hold.new(item:, member:, creator: member.user)
      assert_not hold.valid?
      assert_equal ["can not be placed on hold"], hold.errors[:item]
    end
  end
end

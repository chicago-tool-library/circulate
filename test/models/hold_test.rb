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
    refute hold.inactive?
    refute hold.ended?
    refute hold.expired?
    refute hold.started?

    assert Hold.active.find_by(id: hold)
    refute Hold.inactive.find_by(id: hold)
    refute Hold.ended.find_by(id: hold)
    refute Hold.expired.find_by(id: hold)
    refute Hold.started.find_by(id: hold)
  end

  test "started hold" do
    hold = create(:hold, ended_at: nil, started_at: 1.day.ago)

    assert hold.active?
    refute hold.inactive?
    refute hold.ended?
    refute hold.expired?
    assert hold.started?

    assert Hold.active.find_by(id: hold)
    refute Hold.inactive.find_by(id: hold)
    refute Hold.ended.find_by(id: hold)
    refute Hold.expired.find_by(id: hold)
    assert Hold.started.find_by(id: hold)
  end

  test "ended hold" do
    hold = create(:hold, ended_at: 3.days.ago, started_at: 10.days.ago)

    refute hold.active?
    assert hold.inactive?
    assert hold.ended?
    refute hold.expired?
    assert hold.started?

    refute Hold.active.find_by(id: hold)
    assert Hold.inactive.find_by(id: hold)
    assert Hold.ended.find_by(id: hold)
    refute Hold.expired.find_by(id: hold)
    assert Hold.started.find_by(id: hold)
  end

  test "expired hold" do
    hold = create(:hold, ended_at: nil, started_at: 15.days.ago)

    refute hold.active?
    assert hold.inactive?
    refute hold.ended?
    assert hold.expired?
    assert hold.started?

    refute Hold.active.find_by(id: hold)
    assert Hold.inactive.find_by(id: hold)
    refute Hold.ended.find_by(id: hold)
    assert Hold.expired.find_by(id: hold)
    assert Hold.started.find_by(id: hold)
  end
end

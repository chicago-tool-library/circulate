require "test_helper"

class ReservationPolicyTest < ActiveSupport::TestCase
  test "validations" do
    reservation_policy = build(:reservation_policy)
    reservation_policy.valid?
    assert_equal({}, reservation_policy.errors.messages)

    reservation_policy = ReservationPolicy.new

    assert reservation_policy.invalid?
    assert_equal ["can't be blank"], reservation_policy.errors[:name]

    reservation_policy = ReservationPolicy.new(maximum_duration: 0, minimum_start_distance: -1, maximum_start_distance: 0)
    assert reservation_policy.invalid?
    assert_equal ["must be greater than 0"], reservation_policy.errors[:maximum_duration]
    assert_equal ["must be greater than or equal to 0"], reservation_policy.errors[:minimum_start_distance]
    assert_equal ["must be greater than 0"], reservation_policy.errors[:maximum_start_distance]

    reservation_policy = ReservationPolicy.new(minimum_start_distance: 3, maximum_start_distance: 2)
    assert reservation_policy.invalid?
    assert_equal ["must be greater than the mininum start distance"], reservation_policy.errors[:maximum_start_distance]

    existing_reservation_policy = create(:reservation_policy)
    reservation_policy = build(:reservation_policy, name: existing_reservation_policy.name)
    assert reservation_policy.invalid?
    assert_equal ["has already been taken"], reservation_policy.errors[:name]
  end

  test "after saving as default it ensures there are no other defaults" do
    default_query = ReservationPolicy.where(default: true)

    original_default = create(:reservation_policy, default: true)
    other = build(:reservation_policy, default: false)

    assert_equal 1, default_query.count

    other.default = true

    assert other.save
    assert other.reload.default?
    refute original_default.reload.default?
    assert_equal 1, default_query.count

    assert original_default.update(default: true)
    assert original_default.reload.default?
    refute other.reload.default?
    assert_equal 1, default_query.count
  end

  test "acts as a tenant" do
    chicago = create(:library)
    denver = create(:library)

    ActsAsTenant.with_tenant(chicago) do
      reservation_policies = create_list(:reservation_policy, 2)

      assert_equal reservation_policies.size, ReservationPolicy.count

      reservation_policies.each do |reservation_policy|
        assert_equal chicago, reservation_policy.library
      end
    end

    ActsAsTenant.with_tenant(denver) do
      reservation_policies = create_list(:reservation_policy, 3)

      assert_equal reservation_policies.size, ReservationPolicy.count

      reservation_policies.each do |reservation_policy|
        assert_equal denver, reservation_policy.library
      end
    end

    ActsAsTenant.without_tenant do
      assert_equal 5, ReservationPolicy.count
    end
  end

  test ".default_policy is the only default policy" do
    create(:reservation_policy, default: false)
    default_policy = create(:reservation_policy, default: true)
    create(:reservation_policy, default: false)

    assert_equal default_policy, ReservationPolicy.default_policy
  end

  test ".default_policy is an new reservation policy when there is no default policy saved" do
    create(:reservation_policy, default: false)

    default_policy = ReservationPolicy.default_policy
    assert default_policy.default?
    assert_equal "System Default", default_policy.name
  end
end

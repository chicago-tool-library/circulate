require "test_helper"

class LibraryTest < ActiveSupport::TestCase
  test "validations" do
    library = Library.new

    assert library.invalid?
    assert_equal ["can't be blank"], library.errors[:name]
    assert_equal ["can't be blank"], library.errors[:hostname]
    assert library.errors[:member_postal_code_pattern].blank?

    library = Library.new(name: "Another CTL", hostname: libraries(:chicago_tool_library).hostname)

    assert library.invalid?
    assert_equal ["has already been taken"], library.errors[:hostname]

    library = Library.new(member_postal_code_pattern: "[)")

    assert library.invalid?
    assert_equal ["is invalid"], library.errors[:member_postal_code_pattern]

    library = Library.new(maximum_reservation_length: 0, minimum_reservation_start_distance: -1, maximum_reservation_start_distance: 0)
    assert library.invalid?
    assert_equal ["must be greater than 0"], library.errors[:maximum_reservation_length]
    assert_equal ["must be greater than or equal to 0"], library.errors[:minimum_reservation_start_distance]
    assert_equal ["must be greater than 0"], library.errors[:maximum_reservation_start_distance]

    library = Library.new(minimum_reservation_start_distance: 3, maximum_reservation_start_distance: 2)
    assert library.invalid?
    assert_equal ["must be greater than the mininum reservation start distance"], library.errors[:maximum_reservation_start_distance]
  end

  test "checks postal codes against pattern" do
    library = build(:library, member_postal_code_pattern: "^902|19013")

    assert library.allows_postal_code?("90215")
    assert library.allows_postal_code?("19013")
    refute library.allows_postal_code?("19011")
    refute library.allows_postal_code?("90310")
  end

  test "allows any postal code when pattern is not set" do
    library = build(:library, member_postal_code_pattern: "")

    assert library.allows_postal_code?("90215")
    assert library.allows_postal_code?("19013")
    assert library.allows_postal_code?("19011")
    assert library.allows_postal_code?("90310")
  end

  test "#admissible_postal_codes returns list of admissible postal codes" do
    library = build(:library, member_postal_code_pattern: "12345|67890")

    assert_equal %w[12345 67890], library.admissible_postal_codes
  end

  test "#admissible_postal_codes pads results with the letter x if needed" do
    library = build(:library, member_postal_code_pattern: "00000|^1111|^222|^33|^4")

    assert_equal %w[00000 1111x 222xx 33xxx 4xxxx], library.admissible_postal_codes
  end

  test "#valid_reservation_started_at?" do
    library = build(:library, minimum_reservation_start_distance: 3, maximum_reservation_start_distance: 7)

    assert library.valid_reservation_started_at?(3.days.from_now)
    assert library.valid_reservation_started_at?(7.days.from_now)

    refute library.valid_reservation_started_at?(2.days.from_now)
    refute library.valid_reservation_started_at?(8.days.from_now)
  end
end

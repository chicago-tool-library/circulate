require "test_helper"

class LibraryTest < ActiveSupport::TestCase
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
end

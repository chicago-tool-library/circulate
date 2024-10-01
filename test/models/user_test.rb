require "test_helper"

class UserTest < ActiveSupport::TestCase
  [
    :user,
    [:user, :unconfirmed],
    :member_user,
    :staff_user,
    :admin_user,
    :super_admin_user
  ].each do |factory_name|
    test "#{Array(factory_name).join(", ")} is a valid factory/trait" do
      user = build(*factory_name)
      user.valid?
      assert_equal({}, user.errors.messages)
    end
  end

  test "validations" do
    user = build(:user, email: "")
    assert user.invalid?
    assert_equal ["can't be blank"], user.errors[:email]

    user = build(:user, email: "invalid format")
    assert user.invalid?
    assert_equal ["is invalid"], user.errors[:email]

    user = build(:user, password: "")
    assert user.invalid?
    assert_equal ["can't be blank"], user.errors[:password]

    user = build(:user, password: "123")
    assert user.invalid?
    assert_equal ["is too short (minimum is 6 characters)"], user.errors[:password]
  end

  test "validates email uniqueness is scoped to library" do
    chicago = create(:library, name: "chicago")
    denver = create(:library, name: "denver")

    existing_chicago_user = nil

    ActsAsTenant.with_tenant(chicago) do
      existing_chicago_user = create(:user, library: chicago)
      new_chicago_user = build(:user, email: existing_chicago_user.email, library: chicago)

      assert new_chicago_user.invalid?
      assert_equal ["has already been taken"], new_chicago_user.errors[:email]
    end

    ActsAsTenant.with_tenant(denver) do
      new_denver_user = build(:user, email: existing_chicago_user.email, library: denver)
      assert new_denver_user.valid?
      assert new_denver_user.save
      assert_equal existing_chicago_user.email, new_denver_user.email
    end
  end

  test ".find_by_case_insensitive_email" do
    original_user = create(:user, email: "myMixedCaseEmail@example.com")

    assert_equal original_user, User.find_by_case_insensitive_email(original_user.email.upcase)
    assert_equal original_user, User.find_by_case_insensitive_email(original_user.email.downcase)
    assert_nil User.find_by_case_insensitive_email("myMixedCaseEmail@example.co")
  end
end

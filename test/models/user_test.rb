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

  test ".find_by_case_insensitive_email" do
    original_user = create(:user, email: "myMixedCaseEmail@example.com")

    assert_equal original_user, User.find_by_case_insensitive_email(original_user.email.upcase)
    assert_equal original_user, User.find_by_case_insensitive_email(original_user.email.downcase)
    assert_nil User.find_by_case_insensitive_email("myMixedCaseEmail@example.co")
  end
end

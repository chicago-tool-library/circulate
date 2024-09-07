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
end

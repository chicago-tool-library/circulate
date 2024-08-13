require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "factory definitions" do
    assert_nothing_raised do
      create(:notification)
    end
  end
end

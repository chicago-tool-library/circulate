# frozen_string_literal: true

require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "factory definitions" do
    create(:notification)
  end
end

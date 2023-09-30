# frozen_string_literal: true

require "test_helper"

class NullBorrowPolicyTest < ActiveSupport::TestCase
  setup do
    @policy = NullBorrowPolicy.new
  end

  test "borrow policy API" do
    @policy.member_renewable?
  end
end

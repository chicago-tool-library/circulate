# frozen_string_literal: true

require "test_helper"

class ResultTest < ActiveSupport::TestCase
  test "is successful" do
    result = Result.success("🎉")

    assert result.success?
    assert_not result.failure?

    assert_equal "🎉", result.value
  end

  test "is a failure" do
    result = Result.failure("something bad happened")

    assert result.failure?
    assert_not result.success?

    assert_equal "something bad happened", result.error
    assert_nil result.value
  end
end

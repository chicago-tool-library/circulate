require "test_helper"

class ResultTest < ActiveSupport::TestCase
  test "is successful" do
    result = Result.success("🎉")

    assert result.success?
    refute result.failure?

    assert_equal "🎉", result.value
  end

  test "is a failure" do
    result = Result.failure(["something bad happened"])

    assert result.failure?
    refute result.success?

    assert_equal ["something bad happened"], result.errors
    assert_nil result.value
  end
end

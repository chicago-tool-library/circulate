require "test_helper"

class RequiredAnswerTest < ActiveSupport::TestCase
  test "validations" do
    required_answer = build(:required_answer)
    required_answer.valid?
    assert_equal({}, required_answer.errors.messages)

    required_answer = RequiredAnswer.new

    assert required_answer.invalid?
    assert_equal ["can't be blank"], required_answer.errors[:result]
    assert_equal ["can't be blank"], required_answer.errors[:value]
  end
end

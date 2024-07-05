require "test_helper"

class StemTest < ActiveSupport::TestCase
  test "validations" do
    stem = build(:stem)
    stem.valid?
    assert_equal({}, stem.errors.messages)

    stem = Stem.new

    assert stem.invalid?
    assert_equal ["can't be blank"], stem.errors[:content]
    assert_equal ["can't be blank"], stem.errors[:answer_type]
  end
end

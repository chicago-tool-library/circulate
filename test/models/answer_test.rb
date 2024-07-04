require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  test "validations" do
    answer = build(:answer)
    answer.valid?
    assert_equal({}, answer.errors.messages)

    answer = Answer.new

    assert answer.invalid?
    assert_equal ["can't be blank"], answer.errors[:result]

    existing_answer = create(:answer)
    answer = build(:answer, stem: existing_answer.stem, reservation: existing_answer.reservation)

    assert answer.invalid?
    assert ["already taken"], answer.errors[:reservation_id]
  end

  test "#value returns the correct value for the associated stem's answer type" do
    text_stem = create(:stem, :text)
    integer_stem = create(:stem, :integer)

    answer = Answer.new(result: {"text" => "text result", "integer" => 15})

    assert_nil answer.value

    answer.stem = text_stem
    assert_equal "text result", answer.value

    answer.stem = integer_stem
    assert_equal 15, answer.value

    answer.result = nil
    assert_nil answer.value
  end

  test "#value= sets the value in the result" do
    text_stem = create(:stem, :text)
    integer_stem = create(:stem, :integer)

    answer = Answer.new

    answer.stem = text_stem
    answer.value = "some text"
    assert_equal "some text", answer.value
    assert_equal ({"text" => "some text"}), answer.result

    answer.stem = integer_stem
    answer.value = 5
    assert_equal 5, answer.value
    assert_equal ({"integer" => 5}), answer.result

    answer.stem = nil

    assert_raises ArgumentError do
      answer.value = 3
    end
  end
end

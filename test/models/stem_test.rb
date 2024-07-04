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
    assert_equal ["can't be blank"], stem.errors[:version]

    existing_stem = create(:stem)
    stem = build(:stem, question: existing_stem.question, version: existing_stem.version)

    assert stem.invalid?
    assert_equal ["has already been taken"], stem.errors[:version]

    stem = build(:stem, version: existing_stem.version)
    assert stem.valid?
  end

  test "#version is set to be one more than the its sibling's version (largest one) unless the version is already set" do
    create(:stem) # ignored
    question = create(:question)

    stem = create(:stem, question:)
    assert_equal 1, stem.version

    stem = create(:stem, question:)
    assert_equal 2, stem.version

    stem = create(:stem, question:, version: 5)
    assert_equal 5, stem.version

    stem = create(:stem, question:)
    assert_equal 6, stem.version
  end
end

require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  test "validations" do
    question = build(:question)
    question.valid?
    assert_equal({}, question.errors.messages)

    question = Question.new

    assert question.invalid?
    assert_equal ["can't be blank"], question.errors[:name]

    existing_question = create(:question)
    question = build(:question, name: existing_question.name)

    assert question.invalid?
    assert_equal ["has already been taken"], question.errors[:name]
  end

  test "acts as a tenant" do
    chicago = create(:library)
    denver = create(:library)

    ActsAsTenant.with_tenant(chicago) do
      questions = create_list(:question, 2)

      assert_equal questions.size, Question.count

      questions.each do |question|
        assert_equal chicago, question.library
      end
    end

    ActsAsTenant.with_tenant(denver) do
      questions = create_list(:question, 3)

      assert_equal questions.size, Question.count

      questions.each do |question|
        assert_equal denver, question.library
      end
    end

    ActsAsTenant.without_tenant do
      assert_equal 5, Question.count
    end
  end

  test "#stem is the most recently created stem associated with the question" do
    other_question, question = create_list(:question, 2)
    create(:stem, question: other_question)

    assert_nil question.reload.stem

    first_stem = create(:stem, question:)
    assert_equal first_stem, question.reload.stem

    second_stem = create(:stem, question:)
    assert_equal second_stem, question.reload.stem

    create(:stem, question: other_question)
    assert_equal second_stem, question.reload.stem
  end
end

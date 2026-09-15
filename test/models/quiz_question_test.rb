require "test_helper"

class QuizQuestionTest < ActiveSupport::TestCase
  test "needs at least two answers" do
    question = QuizQuestion.new(content: "How long is a loan?")
    question.choices.build(content: "7 days", correct: true)

    assert_not question.valid?
    assert_includes question.errors[:choices], "must include at least two answers"
  end

  test "needs a correct answer" do
    question = QuizQuestion.new(content: "How long is a loan?")
    question.choices.build(content: "7 days")
    question.choices.build(content: "3 days")

    assert_not question.valid?
    assert_includes question.errors[:choices], "must mark one answer as correct"
  end

  test "ignores answers marked for removal when validating" do
    question = create(:quiz_question)
    question.choices.first.mark_for_destruction

    assert_not question.valid?
  end
end

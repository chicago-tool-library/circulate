# Shared between the signup and renewal wizards, which both ask the policy
# quiz right after the rules step whenever staff have written questions.
#
# Answers live in the session and are deliberately never tied to a member:
# the only thing persisted is a per-answer counter, which is enough for
# staff to spot a confusing slide without grading anyone. It also sidesteps
# the fact that during signup there is no member yet at this step.
module PolicyQuizStep
  extend ActiveSupport::Concern

  included do
    helper_method :quiz_enabled?
  end

  def quiz_enabled?
    QuizQuestion.active.exists?
  end

  def quiz_questions
    @quiz_questions ||= QuizQuestion.active.ordered.includes(:choices).to_a
  end

  # Session keys come back as strings after the cookie round trip.
  def quiz_answers
    session[:quiz_answers] || {}
  end

  def quiz_answer_for(question)
    choice_id = quiz_answers[question.id.to_s]
    question.choices.find { |choice| choice.id == choice_id } if choice_id
  end

  def record_quiz_answer(question, choice)
    return if quiz_answers.key?(question.id.to_s)

    QuizChoice.increment_counter(:times_chosen, choice.id)
    session[:quiz_answers] = quiz_answers.merge(question.id.to_s => choice.id)
  end

  # 1-based position of the first question without an answer, or the last
  # question once everything has been answered.
  def next_quiz_question_number
    index = quiz_questions.index { |question| quiz_answer_for(question).nil? }
    index ? index + 1 : quiz_questions.size
  end
end

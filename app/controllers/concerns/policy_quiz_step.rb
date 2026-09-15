# Shared between the signup and renewal wizards, which both show the policy
# presentation on the rules step and ask the quiz right after it.
#
# Answers live in the session and are deliberately never tied to a member:
# the only thing persisted is a per-answer counter, which is enough for
# staff to spot a confusing slide without grading anyone. It also sidesteps
# the fact that during signup there is no member yet at this step.
module PolicyQuizStep
  extend ActiveSupport::Concern

  included do
    helper_method :orientation_enabled?, :quiz_enabled?, :policy_deck_url, :policy_deck_embed_url, :orientation_preview?
  end

  # Staff set up the presentation and draft questions with the orientation
  # switched off, then turn the whole thing on from the Orientation page.
  # Until then members see the policy text exactly as before. An admin who
  # started a preview from that page sees all of it regardless.
  def orientation_enabled?
    current_library.orientation_enabled? || orientation_preview?
  end

  def quiz_enabled?
    orientation_enabled? && QuizQuestion.active.exists?
  end

  # Public Canva "view" URL for the presentation. When present, the rules
  # step embeds the deck instead of rendering the policy document body on
  # its own.
  def policy_deck_url
    current_library.policy_deck_url.presence if orientation_enabled?
  end

  def policy_deck_embed_url
    "#{policy_deck_url}?embed"
  end

  def orientation_preview?
    session[:orientation_preview].present? && current_user&.has_role?(:admin) || false
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

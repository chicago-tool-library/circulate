# The one-question-at-a-time quiz, shared by the signup and renewal
# controllers. Each question is its own page: answering it redirects back to
# the same page, which then shows the right answer and the explanation before
# moving on. Including controllers provide quiz_question_url_for(number) and
# after_quiz_url.
module QuizFlow
  extend ActiveSupport::Concern

  included do
    before_action :require_quiz
    before_action :load_question, only: [:question, :answer]
  end

  def show
    redirect_to quiz_question_url_for(next_quiz_question_number)
  end

  def question
    @chosen = quiz_answer_for(@question)
    @next_url = @last ? after_quiz_url : quiz_question_url_for(@number + 1)
    activate_step(:quiz)
  end

  def answer
    chosen = @question.choices.find { |choice| choice.id == params[:choice_id].to_i }

    if chosen
      record_quiz_answer(@question, chosen)
    else
      flash[:error] = "Pick an answer to continue."
    end
    redirect_to quiz_question_url_for(@number)
  end

  private

  def require_quiz
    redirect_to after_quiz_url unless quiz_enabled?
  end

  def load_question
    @number = params[:number].to_i
    @question = quiz_questions[@number - 1] if @number.positive?
    return redirect_to quiz_question_url_for(next_quiz_question_number) if @question.nil?

    @total = quiz_questions.size
    @last = @number == @total
  end
end

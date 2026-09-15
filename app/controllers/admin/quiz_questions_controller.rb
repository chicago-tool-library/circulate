module Admin
  class QuizQuestionsController < BaseController
    before_action :set_quiz_question, only: %i[edit update archive unarchive]

    def index
      @quiz_questions = QuizQuestion.ordered.includes(:choices)
    end

    def new
      @quiz_question = QuizQuestion.new
      @quiz_question.position = (QuizQuestion.maximum(:position) || 0) + 1
      3.times { @quiz_question.choices.build }
    end

    def edit
    end

    def create
      @quiz_question = QuizQuestion.new(quiz_question_params)

      if @quiz_question.save
        redirect_to admin_quiz_questions_url, success: "Question was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @quiz_question.update(quiz_question_params)
        redirect_to admin_quiz_questions_url, success: "Question was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def archive
      @quiz_question.update!(archived_at: Time.current)
      redirect_to admin_quiz_questions_url, success: "Question was archived. It won't be shown to members anymore."
    end

    def unarchive
      @quiz_question.update!(archived_at: nil)
      redirect_to admin_quiz_questions_url, success: "Question was unarchived."
    end

    private

    def set_quiz_question
      @quiz_question = QuizQuestion.find(params[:id])
    end

    def quiz_question_params
      params.require(:quiz_question).permit(:content, :explanation, :position, choices_attributes: [:id, :content, :correct, :position, :_destroy])
    end
  end
end

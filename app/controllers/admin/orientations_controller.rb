module Admin
  # Everything staff can change about new member orientation in one place:
  # the presentation shown on the rules step and the quiz that follows it.
  class OrientationsController < BaseController
    before_action :require_admin

    def show
      @library = current_library
      @quiz_questions = QuizQuestion.ordered.includes(:choices)
    end

    def update
      if current_library.update(orientation_params)
        redirect_to admin_orientation_url, success: "Orientation settings updated", status: :see_other
      else
        @library = current_library
        @quiz_questions = QuizQuestion.ordered.includes(:choices)
        render :show, status: :unprocessable_content
      end
    end

    private

    def orientation_params
      params.require(:library).permit(:policy_deck_url, :orientation_enabled)
    end
  end
end

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

    # Walk through the rules step and the quiz as a member would, even while
    # the orientation is switched off. The flag lives in the admin's own
    # session, so members are never affected.
    def preview
      session[:orientation_preview] = true
      redirect_to signup_rules_url
    end

    def end_preview
      session.delete(:orientation_preview)
      redirect_to admin_orientation_url
    end

    private

    def orientation_params
      params.require(:library).permit(:policy_deck_url, :orientation_enabled)
    end
  end
end

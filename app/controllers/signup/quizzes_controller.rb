module Signup
  class QuizzesController < BaseController
    include QuizFlow

    before_action :is_membership_enabled?

    private

    def quiz_question_url_for(number)
      signup_quiz_question_url(number)
    end

    def after_quiz_url
      new_signup_member_url
    end
  end
end

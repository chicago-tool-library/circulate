module Renewal
  class QuizzesController < BaseController
    include QuizFlow

    private

    def quiz_question_url_for(number)
      renewal_quiz_question_url(number)
    end

    def after_quiz_url
      edit_renewal_member_url
    end
  end
end

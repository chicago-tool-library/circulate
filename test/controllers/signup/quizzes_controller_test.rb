require "test_helper"

module Signup
  class QuizzesControllerTest < ActionDispatch::IntegrationTest
    setup do
      create(:agreement_document)
      create(:document, code: "borrow_policy")
    end

    test "rules step skips the quiz when there are no questions" do
      get signup_rules_url

      assert_response :success
      assert_select "a[href='#{new_signup_member_url}']", text: "Continue"
      assert_select ".step-item", text: "Quiz", count: 0
    end

    test "rules step continues to the quiz when questions exist" do
      create(:quiz_question)

      get signup_rules_url

      assert_response :success
      assert_select "a[href='#{signup_quiz_url}']", text: "Continue"
      assert_select ".step-item", text: "Quiz"
    end

    test "quiz redirects to profile when there are no questions" do
      get signup_quiz_url

      assert_redirected_to new_signup_member_url
    end

    test "quiz starts at the first question" do
      create(:quiz_question, content: "First question?")
      create(:quiz_question, content: "Second question?")

      get signup_quiz_url
      assert_redirected_to signup_quiz_question_url(1)

      follow_redirect!
      assert_select "p", text: /First question\?/
      assert_select "p", text: /Second question\?/, count: 0
      assert_select ".policy-quiz-progress", text: "Question 1 of 2"
    end

    test "archived questions are left out" do
      create(:quiz_question, content: "Active question?")
      create(:quiz_question, content: "Old question?", archived_at: 1.day.ago)

      get signup_quiz_question_url(1)
      assert_select "p", text: /Active question\?/
      assert_select ".policy-quiz-progress", text: "Question 1 of 1"

      get signup_quiz_question_url(2)
      assert_redirected_to signup_quiz_question_url(1)
    end

    test "asks again when no answer is picked" do
      create(:quiz_question)

      post signup_quiz_question_url(1)

      assert_redirected_to signup_quiz_question_url(1)
      assert_equal "Pick an answer to continue.", flash[:error]
    end

    test "a wrong answer shows the right one and counts once" do
      question = create(:quiz_question)
      create(:quiz_question)
      right, wrong = question.choices.to_a

      post signup_quiz_question_url(1), params: {choice_id: wrong.id}
      assert_redirected_to signup_quiz_question_url(1)
      assert_equal 1, wrong.reload.times_chosen
      assert_equal 0, right.reload.times_chosen

      follow_redirect!
      assert_select ".instructions .main", text: "Not quite."
      assert_select ".policy-quiz-result.is-incorrect"
      assert_select "li.is-correct", text: /Right/
      assert_select "li.is-chosen", text: /Wrong/
      assert_select ".policy-quiz-explanation", text: "Here's why."
      assert_select "a[href='#{signup_quiz_question_url(2)}']", text: "Next question"

      # Answering again doesn't change the recorded answer or the count.
      post signup_quiz_question_url(1), params: {choice_id: right.id}
      assert_equal 1, wrong.reload.times_chosen
      assert_equal 0, right.reload.times_chosen
    end

    test "the last question continues to the profile" do
      question = create(:quiz_question)

      post signup_quiz_question_url(1), params: {choice_id: question.correct_choice.id}
      follow_redirect!

      assert_select ".instructions .main", text: "That's right!"
      assert_select "a[href='#{new_signup_member_url}']", text: "Continue"
    end

    test "returning to the quiz picks up at the first unanswered question" do
      first = create(:quiz_question)
      create(:quiz_question)

      post signup_quiz_question_url(1), params: {choice_id: first.correct_choice.id}
      get signup_quiz_url

      assert_redirected_to signup_quiz_question_url(2)
    end
  end
end

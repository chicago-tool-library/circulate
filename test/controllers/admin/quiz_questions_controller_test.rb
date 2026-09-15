require "test_helper"

module Admin
  class QuizQuestionsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:admin_user)
      sign_in @user
    end

    test "lists questions with their answers and counts" do
      question = create(:quiz_question)
      question.choices.first.update!(times_chosen: 3)

      get admin_quiz_questions_url

      assert_response :success
      assert_select "td", text: /#{question.content}/
      assert_select ".label", text: "3 picks"
    end

    test "creates a question with its answers" do
      assert_difference("QuizQuestion.count") do
        post admin_quiz_questions_url, params: {
          quiz_question: {
            content: "How long is a loan?",
            explanation: "Seven days.",
            position: 1,
            choices_attributes: {
              "0" => {content: "7 days", correct: "1"},
              "1" => {content: "30 days", correct: "0"},
              "2" => {content: "", correct: "0"}
            }
          }
        }
      end

      assert_redirected_to admin_quiz_questions_url
      question = QuizQuestion.last
      assert_equal ["7 days", "30 days"], question.choices.map(&:content)
      assert_equal "7 days", question.correct_choice.content
    end

    test "rejects a question with no correct answer" do
      assert_no_difference("QuizQuestion.count") do
        post admin_quiz_questions_url, params: {
          quiz_question: {
            content: "How long is a loan?",
            choices_attributes: {
              "0" => {content: "7 days", correct: "0"},
              "1" => {content: "30 days", correct: "0"}
            }
          }
        }
      end

      assert_response :unprocessable_content
    end

    test "archives and unarchives a question" do
      question = create(:quiz_question)

      patch archive_admin_quiz_question_url(question)
      assert question.reload.archived?

      patch unarchive_admin_quiz_question_url(question)
      assert_not question.reload.archived?
    end
  end
end

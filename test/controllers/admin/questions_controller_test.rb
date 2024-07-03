require "test_helper"

class Admin::QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:admin_user)
    sign_in @user
  end

  test "getting the index page" do
    create_list(:question, 3)
    get admin_questions_url
    assert_response :success
  end

  test "getting the new page" do
    get new_admin_question_url
    assert_response :success
  end

  test "creating a reservation policy" do
    attributes = attributes_for(:question)
    assert_difference("Question.count", 1) do
      post admin_questions_url, params: {question: attributes.slice(:name)}
    end

    assert_redirected_to admin_question_url(Question.last)
  end

  test "getting the show page" do
    question = create(:question)
    get admin_question_url(question)
    assert_response :success
  end

  test "getting the edit page" do
    question = create(:question)
    get edit_admin_question_url(question)
    assert_response :success
  end

  test "updating a reservation policy" do
    attributes = attributes_for(:question)
    question = create(:question)

    patch admin_question_url(question), params: {question: attributes.slice(:name)}
    assert_redirected_to admin_question_url(question)
  end
end

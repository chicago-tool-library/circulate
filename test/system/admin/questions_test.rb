require "application_system_test_case"

class AdminQuestionsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @attributes = attributes_for(:question).slice(:name)
  end

  test "visiting the index" do
    questions = create_list(:question, 3)

    visit admin_questions_url

    questions.each do |question|
      assert_text question.name
    end
  end

  test "viewing a question" do
    question = create(:question)

    visit admin_questions_url
    click_on question.name

    assert_text question.name
    assert_equal admin_question_path(question), current_path
  end

  test "creating a question successfully" do
    visit admin_questions_url
    click_on "New question"

    fill_in "Name", with: @attributes[:name]

    assert_difference("Question.count", 1) do
      click_on "Create Question"
      assert_text "Question was successfully created"
    end

    question = Question.last!

    assert_equal admin_question_path(question), current_path
    assert_equal @attributes[:name], question.name
  end

  test "creating a question with errors" do
    existing_question = create(:question)
    visit admin_questions_url
    click_on "New question"

    fill_in "Name", with: existing_question.name

    assert_difference("Question.count", 0) do
      click_on "Create Question"
      assert_text "has already been taken"
    end
  end

  test "updating a question successfully" do
    question = create(:question)
    visit admin_question_path(question)
    click_on "Edit"

    fill_in "Name", with: @attributes[:name]

    assert_difference("Question.count", 0) do
      click_on "Update Question"
      assert_text "Question was successfully updated"
    end

    question.reload

    assert_equal admin_question_path(question), current_path
    assert_equal @attributes[:name], question.name
  end

  test "updating a question with errors" do
    existing_question = create(:question)
    question = create(:question)
    visit admin_question_path(question)
    click_on "Edit"

    fill_in "Name", with: existing_question.name

    assert_difference("Question.count", 0) do
      click_on "Update Question"
      assert_text "has already been taken"
    end

    question.reload

    refute_equal @attributes[:name], question.name
  end
end

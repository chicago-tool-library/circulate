require "application_system_test_case"

class AdminQuestionsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @attributes = attributes_for(:question).slice(:name)
    @stem_attributes = attributes_for(:stem).slice(:answer_type, :content)
  end

  test "visiting the index" do
    questions = create_list(:question, 3)

    questions_with_stems = questions.first(2).each do |question|
      create(:stem, question:)
    end

    archived_question = questions.first
    archived_question.update!(archived_at: Time.current)

    visit admin_questions_url

    questions.each do |question|
      assert_text question.name
    end

    questions_with_stems.each do |question|
      assert_text question.stem.content
      assert_text question.stem.answer_type
    end

    assert_text archived_question.archived_at.to_date.to_s
  end

  test "viewing a question with a stem" do
    question = create(:question, archived_at: 3.days.ago)
    stem = create(:stem, question:)

    visit admin_questions_url
    click_on question.name

    assert_text question.name
    assert_equal admin_question_path(question), current_path
    assert_text question.archived_at.to_date.to_s
    assert_text stem.content
    assert_text stem.answer_type
  end

  test "viewing a question without a stem" do
    question = create(:question)

    visit admin_questions_url
    click_on question.name

    assert_text question.name
    assert_equal admin_question_path(question), current_path
    assert_text "Please edit to add question content"
  end

  test "archiving a question" do
    question = create(:question, :unarchived)

    visit admin_question_path(question)

    refute_text "Unarchive"

    accept_confirm { click_on "Archive" }

    assert_text "Question was successfully archived"

    question.reload

    assert question.archived_at?
    assert_equal Date.today, question.archived_at.to_date
  end

  test "unarchiving a question" do
    question = create(:question, :archived)

    visit admin_question_path(question)

    refute_text "Archive"

    accept_confirm { click_on "Unarchive" }

    assert_text "Question was successfully unarchived"

    question.reload

    refute question.archived_at?
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

  test "creating a question with a stem successfully" do
    visit admin_questions_url
    click_on "New question"

    fill_in "Name", with: @attributes[:name]
    fill_in "Content", with: @stem_attributes[:content]
    select @stem_attributes[:answer_type].capitalize, from: "Answer type"

    assert_equal 0, Stem.count

    assert_difference("Question.count", 1) do
      click_on "Create Question"
      assert_text "Question was successfully created"
    end

    assert_equal 1, Stem.count

    question = Question.last!

    assert_equal admin_question_path(question), current_path
    assert_equal @attributes[:name], question.name
    assert question.stem.present?
    assert @stem_attributes[:answer_type], question.stem.answer_type
    assert @stem_attributes[:content], question.stem.content
  end

  test "updating a question successfully" do
    question = create(:question)
    stem = create(:stem, question:)
    visit admin_question_path(question)
    click_on "Edit"

    fill_in "Name", with: @attributes[:name]
    fill_in "Content", with: @stem_attributes[:content]
    select @stem_attributes[:answer_type].capitalize, from: "Answer type"

    assert_equal 1, Stem.count

    assert_difference("Question.count", 0) do
      click_on "Update Question"
      assert_text "Question was successfully updated"
    end

    assert_equal 2, Stem.count

    question.reload

    assert_equal admin_question_path(question), current_path
    assert_equal @attributes[:name], question.name
    assert question.stem.present?
    refute_equal stem, question.stem
    assert @stem_attributes[:answer_type], question.stem.answer_type
    assert @stem_attributes[:content], question.stem.content
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

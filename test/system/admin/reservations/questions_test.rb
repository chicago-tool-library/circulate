require "application_system_test_case"

class AdminReservationsQuestionsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @organization = create(:organization)
    @attributes = attributes_for(:reservation, started_at: 3.days.from_now.at_noon, ended_at: 10.days.from_now.at_noon).slice(:name, :started_at, :ended_at)
  end

  def date_input_format(datetime)
    datetime.strftime("%Y-%m-%d")
  end

  test "viewing a reservation's questions and answers" do
    reservation = create(:reservation)
    create(:answer) # ignored
    answers = create_list(:answer, 2, reservation:)

    visit admin_reservation_url(reservation)
    # TODO: This is a somewhat ambiguous selector that I'm dropping in to fix
    # tests in a sweep. Consider rearranging the view to make it easier to
    # select between the tab and the global nav.
    within(".tab") do
      click_on "Questions"
    end

    answers.each do |answer|
      assert_text answer.stem.content
      assert_text answer.value
    end
  end

  test "creating a reservation with questions and answers" do
    text_stem = create(:stem, :text)
    integer_stem = create(:stem, :integer)
    create(:stem, :archived) # ignored

    visit new_admin_reservation_path
    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))
    select(@organization.name, from: "Organization")
    fill_in text_stem.content, with: "text answer"
    fill_in integer_stem.content, with: "150"

    assert_equal 0, Answer.count
    assert_difference("Answer.count", 2) do
      click_on "Create Reservation"
      assert_text "Reservation was successfully created"
    end

    assert_equal 1, text_stem.answers.count
    assert_equal 1, integer_stem.answers.count
    assert_equal "text answer", text_stem.answers.first.value
    assert_equal 150, integer_stem.answers.first.value
  end

  test "updating a reservation with questions and answers" do
    reservation = create(:reservation)
    text_stem = create(:stem, :text)
    integer_stem = create(:stem, :integer)
    create(:stem, :archived) # ignored
    text_answer = create(:answer, reservation:, stem: text_stem)
    integer_answer = create(:answer, reservation:, stem: integer_stem, value: 3)

    visit admin_reservation_path(reservation)
    click_on "Edit"

    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))
    fill_in text_stem.content, with: "text answer"
    fill_in integer_stem.content, with: "150"

    assert_difference("Answer.count", 0) do
      click_on "Update Reservation"
      assert_text "Reservation was successfully updated"
    end

    text_answer.reload
    integer_answer.reload

    assert_equal "text answer", text_answer.value
    assert_equal 150, integer_answer.value
  end
end

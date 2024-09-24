require "application_system_test_case"

class AccountReservationsQuestionsTest < ApplicationSystemTestCase
  setup do
    ActionMailer::Base.deliveries.clear

    @organization = create(:organization)
    @member = create(:verified_member_with_membership)
    @attributes = attributes_for(:reservation, started_at: 3.days.from_now.at_noon, ended_at: 10.days.from_now.at_noon).slice(:name, :started_at, :ended_at)

    login_as @member.user
  end

  def date_input_format(datetime)
    datetime.strftime("%Y-%m-%d")
  end

  test "viewing a reservation's questions and answers" do
    reservation = create(:reservation)
    create(:answer) # ignored
    answers = create_list(:answer, 2, reservation:)

    visit account_reservation_url(reservation)

    answers.each do |answer|
      assert_text answer.stem.content
      assert_text answer.value
    end
  end

  test "creating a reservation with questions and answers" do
    text_stem = create(:stem, :text)
    integer_stem = create(:stem, :integer)
    create(:stem, :archived) # ignored

    visit new_account_reservation_path
    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))
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

  test "creating a reservation with questions and answers with errors" do
    text_stem = create(:stem, :text)

    visit new_account_reservation_path
    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))
    fill_in text_stem.content, with: ""

    assert_equal 0, Answer.count
    assert_difference("Answer.count", 0) do
      click_on "Create Reservation"
      assert_text "Please correct the errors below"
    end

    assert_equal 0, text_stem.answers.count
    assert_text "can't be blank"
  end
end

require "application_system_test_case"

module Admin
  class AppointmentCheckinsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @member = create(:member)
      @loan = create(:loan, member: @member)
      @appointment = build(:appointment, member: @member)
      @appointment.loans << @loan
      @appointment.save!

      @user = create(:admin_user)
      sign_in @user
    end

    test "returns a single item" do
      post admin_appointment_checkins_path(@appointment), params: {loan_ids: [@loan.id]}
      assert_enqueued_emails 0
    end

    test "notifies the next member in line when returning an item on hold" do
      hold = create(:hold, item: @loan.item)

      assert_enqueued_email_with MemberMailer, :hold_available,
        args: {member: hold.member, hold: hold} do
        post admin_appointment_checkins_path(@appointment), params: {loan_ids: [@loan.id]}
      end
    end

    test "notifies next members in line when returning multiple items on hold" do
      hold = create(:hold, item: @loan.item)

      loan2 = create(:loan, member: @member)
      @appointment.loans << loan2
      @appointment.save
      hold2 = create(:hold, item: loan2.item)

      post admin_appointment_checkins_path(@appointment), params: {loan_ids: [@loan.id, loan2.id]}

      assert_enqueued_email_with MemberMailer, :hold_available, args: {member: hold.member, hold: hold}
      assert_enqueued_email_with MemberMailer, :hold_available, args: {member: hold2.member, hold: hold2}
    end
  end
end

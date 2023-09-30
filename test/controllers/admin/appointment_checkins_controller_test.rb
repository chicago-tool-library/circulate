# frozen_string_literal: true

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
      post admin_appointment_checkins_path(@appointment), params: { loan_ids: [@loan.id] }
      assert_enqueued_emails 0
    end
  end
end

require "test_helper"

module Admin
  class HoldLoansControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @member = create(:member)
      @user = create(:admin_user)
      sign_in @user
    end

    test "lends all holds" do
      holds = 2.times.map {
        create(:hold, member: @member, creator: @user)
      }
      create_open_day_for_loan(holds.first.item)

      assert_difference("@member.loans.count", 2) do
        post admin_member_hold_loan_path(@member)
      end

      holds.each do |hold|
        hold.reload
        assert hold.loan_id
        assert hold.ended_at
      end

      assert_redirected_to admin_member_url(@member)
      # assert flash
    end
  end
end

require "test_helper"

module Account
  class HomeControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)

      sign_in @user
    end

    test "shows nothing with an active membership" do
      create(:membership, member: @member, started_at: 1.week.ago, ended_at: 51.weeks.since)

      get account_home_url
      assert_response :success
    end

    test "shows a message when a membership has less than 30 days left" do
      create(:membership, member: @member, started_at: 336.days.ago, ended_at: 29.days.since)

      get account_home_url
      assert_response :success

      assert_select "div.toast", /Your membership ends on/
      assert_select "a.btn-default", "Renew Membership"
    end

    test "shows a message when a membership has ended" do
      create(:membership, member: @member, started_at: 366.days.ago, ended_at: 1.days.ago)

      get account_home_url
      assert_response :success

      assert_select "div.toast", /Your membership ended on/
      assert_select "a.btn-default", "Renew Membership"
    end

    test "shows updates on the home page" do
      create(:library_update, published: true, body: "some good news")
      create(:library_update, published: false, body: "some old news")

      get account_home_url

      assert_match "some good news", response.body
      refute_match "some old news", response.body
    end
  end
end

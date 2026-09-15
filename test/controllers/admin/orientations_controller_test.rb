require "test_helper"

module Admin
  class OrientationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:admin_user)
      sign_in @user
    end

    test "shows the deck link and the questions with their counts" do
      Library.first.update!(policy_deck_url: "https://www.canva.com/design/ABC/xyz/view")
      question = create(:quiz_question)
      question.choices.first.update!(times_chosen: 3)

      get admin_orientation_url

      assert_response :success
      assert_select "input[name='library[policy_deck_url]'][value='https://www.canva.com/design/ABC/xyz/view']"
      assert_select "td", text: /#{question.content}/
      assert_select ".label", text: "3 picks"
    end

    test "saves the deck link" do
      patch admin_orientation_url, params: {library: {policy_deck_url: "https://www.canva.com/design/ABC/xyz/view"}}

      assert_redirected_to admin_orientation_url
      assert_equal "https://www.canva.com/design/ABC/xyz/view", Library.first.reload.policy_deck_url
    end

    test "turns the orientation on and off" do
      patch admin_orientation_url, params: {library: {orientation_enabled: "1"}}
      assert Library.first.reload.orientation_enabled?

      patch admin_orientation_url, params: {library: {orientation_enabled: "0"}}
      assert_not Library.first.reload.orientation_enabled?
    end

    test "clears the deck link" do
      Library.first.update!(policy_deck_url: "https://www.canva.com/design/ABC/xyz/view")

      patch admin_orientation_url, params: {library: {policy_deck_url: ""}}

      assert_nil Library.first.reload.policy_deck_url.presence
    end

    test "rejects a link that isn't a Canva view link" do
      patch admin_orientation_url, params: {library: {policy_deck_url: "https://www.canva.com/design/ABC/xyz/edit"}}

      assert_response :unprocessable_content
      assert_nil Library.first.reload.policy_deck_url
    end

    test "is only for admins" do
      sign_in create(:user)

      get admin_orientation_url

      assert_redirected_to root_url
    end
  end
end

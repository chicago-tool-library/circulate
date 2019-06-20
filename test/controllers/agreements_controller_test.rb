require 'test_helper'

class AgreementsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @agreement = agreements(:one)
    @user = users(:admin)
    sign_in @user
  end

  test "should get index" do
    get agreements_url
    assert_response :success
  end

  test "should get new" do
    get new_agreement_url
    assert_response :success
  end

  test "should create agreement" do
    assert_difference('Agreement.count') do
      post agreements_url, params: { agreement: { active: @agreement.active, body: @agreement.body, name: @agreement.name, position: @agreement.position, summary: @agreement.summary } }
    end

    assert_redirected_to agreement_url(Agreement.last)
  end

  test "should show agreement" do
    get agreement_url(@agreement)
    assert_response :success
  end

  test "should get edit" do
    get edit_agreement_url(@agreement)
    assert_response :success
  end

  test "should update agreement" do
    patch agreement_url(@agreement), params: { agreement: { active: @agreement.active, body: @agreement.body, name: @agreement.name, position: @agreement.position, summary: @agreement.summary } }
    assert_redirected_to agreement_url(@agreement)
  end

  test "should destroy agreement" do
    assert_difference('Agreement.count', -1) do
      delete agreement_url(@agreement)
    end

    assert_redirected_to agreements_url
  end
end

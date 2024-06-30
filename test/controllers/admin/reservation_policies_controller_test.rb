require "test_helper"

module Admin
  class ReservationPoliciesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:admin_user)
      sign_in @user
    end

    test "getting the index page" do
      create_list(:reservation_policy, 3)
      get admin_reservation_policies_path
      assert_response :success
    end

    test "getting the show page" do
      reservation_policy = create(:reservation_policy)
      get admin_reservation_policy_path(reservation_policy)
      assert_response :success
    end

    test "getting the edit page" do
      reservation_policy = create(:reservation_policy)
      get edit_admin_reservation_policy_path(reservation_policy)
      assert_response :success
    end

    test "getting the new page" do
      get new_admin_reservation_policy_path
      assert_response :success
    end

    test "creating a reservation policy" do
      attributes = attributes_for(:reservation_policy)
      assert_difference("ReservationPolicy.count", 1) do
        post admin_reservation_policies_path, params: {
          reservation_policy: attributes.slice(
            :default,
            :description,
            :maximum_duration,
            :maximum_start_distance,
            :minimum_start_distance,
            :name
          )
        }
      end
      assert_redirected_to admin_reservation_policy_path(ReservationPolicy.last)
    end

    test "updating a reservation policy" do
      attributes = attributes_for(:reservation_policy)
      reservation_policy = create(:reservation_policy)
      patch admin_reservation_policy_path(reservation_policy), params: {
        reservation_policy: attributes.slice(
          :default,
          :description,
          :maximum_duration,
          :maximum_start_distance,
          :minimum_start_distance,
          :name
        )
      }
      assert_redirected_to admin_reservation_policy_path(reservation_policy)
    end

    test "destroying a reservation policy" do
      reservation_policy = create(:reservation_policy)
      assert_difference("ReservationPolicy.count", -1) do
        delete admin_reservation_policy_path(reservation_policy)
      end
      assert_redirected_to admin_reservation_policies_path
    end
  end
end

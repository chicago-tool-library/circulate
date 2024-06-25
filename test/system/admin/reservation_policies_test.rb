require "application_system_test_case"

class AdminReservationPoliciesTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @attributes = {
      name: "new name",
      description: "new description",
      maximum_duration: 100,
      minimum_start_distance: 4,
      maximum_start_distance: 25
    }
  end

  test "listing reservation policies" do
    reservation_policies = create_list(:reservation_policy, 3)

    visit admin_reservation_policies_path

    reservation_policies.each do |reservation_policy|
      assert_text reservation_policy.name
    end
  end

  test "viewing reservation policy" do
    reservation_policy = create(:reservation_policy, default: true, description: "a description")

    visit admin_reservation_policies_path
    click_on reservation_policy.name

    assert_text reservation_policy.name
    assert_text reservation_policy.description
    assert_text "#{reservation_policy.maximum_duration} days"
    assert_text "#{reservation_policy.minimum_start_distance} days"
    assert_text "#{reservation_policy.maximum_start_distance} days"
    assert_text "Yes"
    assert_equal admin_reservation_policy_path(reservation_policy), current_path
  end

  test "creating a reservation policy successfully" do
    visit admin_reservation_policies_path
    click_on "New Reservation policy"

    fill_in "Name", with: @attributes[:name]
    fill_in "Description", with: @attributes[:description]
    fill_in "Maximum duration", with: @attributes[:maximum_duration]
    fill_in "Minimum start distance", with: @attributes[:minimum_start_distance]
    fill_in "Maximum start distance", with: @attributes[:maximum_start_distance]
    find("label", text: "Default").click # check "default" box

    assert_difference("ReservationPolicy.count", 1) do
      click_on "Create Reservation policy"
      assert_text "Reservation policy was successfully created"
    end

    reservation_policy = ReservationPolicy.last!

    assert_equal admin_reservation_policy_path(reservation_policy), current_path
    assert_equal @attributes[:name], reservation_policy.name
    assert_equal @attributes[:description], reservation_policy.description
    assert_equal @attributes[:maximum_duration], reservation_policy.maximum_duration
    assert_equal @attributes[:minimum_start_distance], reservation_policy.minimum_start_distance
    assert_equal @attributes[:maximum_start_distance], reservation_policy.maximum_start_distance
    assert reservation_policy.default?
  end

  test "creating a reservation policy with errors" do
    existing_reservation_policy = create(:reservation_policy)
    visit admin_reservation_policies_path
    click_on "New Reservation policy"

    fill_in "Name", with: existing_reservation_policy.name

    assert_difference("ReservationPolicy.count", 0) do
      click_on "Create Reservation policy"
      assert_text "has already been taken"
    end
  end

  test "updating a reservation policy successfully" do
    reservation_policy = create(:reservation_policy)
    visit admin_reservation_policy_path(reservation_policy)
    click_on "Edit"

    fill_in "Name", with: @attributes[:name]
    fill_in "Description", with: @attributes[:description]
    fill_in "Maximum duration", with: @attributes[:maximum_duration]
    fill_in "Minimum start distance", with: @attributes[:minimum_start_distance]
    fill_in "Maximum start distance", with: @attributes[:maximum_start_distance]
    find("label", text: "Default").click # check "default" box

    assert_difference("ReservationPolicy.count", 0) do
      click_on "Update Reservation policy"
      assert_text "Reservation policy was successfully updated"
    end

    reservation_policy.reload

    assert_equal admin_reservation_policy_path(reservation_policy), current_path
    assert_equal @attributes[:name], reservation_policy.name
    assert_equal @attributes[:description], reservation_policy.description
    assert_equal @attributes[:maximum_duration], reservation_policy.maximum_duration
    assert_equal @attributes[:minimum_start_distance], reservation_policy.minimum_start_distance
    assert_equal @attributes[:maximum_start_distance], reservation_policy.maximum_start_distance
    assert reservation_policy.default?
  end

  test "updating a reservation policy with errors" do
    existing_reservation_policy = create(:reservation_policy)
    reservation_policy = create(:reservation_policy)
    visit admin_reservation_policy_path(reservation_policy)
    click_on "Edit"

    fill_in "Name", with: existing_reservation_policy.name

    assert_difference("ReservationPolicy.count", 0) do
      click_on "Update Reservation policy"
      assert_text "has already been taken"
    end

    refute_equal @attributes[:name], reservation_policy.name
    refute_equal @attributes[:description], reservation_policy.description
    refute_equal @attributes[:maximum_duration], reservation_policy.maximum_duration
    refute_equal @attributes[:minimum_start_distance], reservation_policy.minimum_start_distance
    refute_equal @attributes[:maximum_start_distance], reservation_policy.maximum_start_distance
  end

  test "destroying a reservation policy" do
    reservation_policy = create(:reservation_policy)
    visit edit_admin_reservation_policy_path(reservation_policy)

    assert_difference("ReservationPolicy.count", -1) do
      find("summary", text: "Destroy this reservation policy?").click
      accept_confirm do
        click_on("Destroy reservation policy")
      end
      assert_text "Reservation policy was successfully destroyed."
    end
  end
end

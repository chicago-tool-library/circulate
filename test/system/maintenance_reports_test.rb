require "application_system_test_case"

class MaintenanceReportsTest < ApplicationSystemTestCase
  setup do
    @maintenance_report = maintenance_reports(:one)
  end

  test "visiting the index" do
    visit maintenance_reports_url
    assert_selector "h1", text: "Maintenance Reports"
  end

  test "creating a Maintenance report" do
    visit maintenance_reports_url
    click_on "New Maintenance Report"

    fill_in "Creator", with: @maintenance_report.creator_id
    fill_in "Time spent", with: @maintenance_report.time_spent
    click_on "Create Maintenance report"

    assert_text "Maintenance report was successfully created"
    click_on "Back"
  end

  test "updating a Maintenance report" do
    visit maintenance_reports_url
    click_on "Edit", match: :first

    fill_in "Creator", with: @maintenance_report.creator_id
    fill_in "Time spent", with: @maintenance_report.time_spent
    click_on "Update Maintenance report"

    assert_text "Maintenance report was successfully updated"
    click_on "Back"
  end

  test "destroying a Maintenance report" do
    visit maintenance_reports_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Maintenance report was successfully destroyed"
  end
end

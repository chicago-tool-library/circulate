require "application_system_test_case"

class AdminItemsInMaintenanceReportTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "shows all of the tickets" do
    tickets = [create(:ticket, :assess), create(:ticket, :parts), create(:ticket, :repairing)]

    visit admin_reports_items_in_maintenance_index_path

    tickets.each do |ticket|
      assert_text ticket.title
      assert_text ticket.item.status
      assert_text ticket.item.number
      assert_text ticket.item.name
      assert_text ticket.status
    end
  end

  test "it does not show resolved or retired tickets" do
    ticket = create(:ticket, :assess)
    ignored_tickets = [create(:ticket, :resolved), create(:ticket, :retired)]

    visit admin_reports_items_in_maintenance_index_path

    assert_text ticket.title
    assert_text ticket.item.status
    assert_text ticket.item.number
    assert_text ticket.item.name
    assert_text ticket.status

    ignored_tickets.each do |ticket|
      refute_text ticket.title
      refute_text ticket.item.name
    end
  end

  test "it can be filtered by ticket status" do
    assess_ticket = create(:ticket, :assess)
    parts_ticket = create(:ticket, :parts)
    repairing_ticket = create(:ticket, :repairing)

    visit admin_reports_items_in_maintenance_index_path

    [assess_ticket, parts_ticket, repairing_ticket].each do |ticket|
      assert_text ticket.title
    end

    select("Assess", from: "Ticket Status")
    click_on "Filter"

    assert_text assess_ticket.title

    [parts_ticket, repairing_ticket].each do |ticket|
      refute_text ticket.title
    end
  end
end

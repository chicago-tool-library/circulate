require "application_system_test_case"

class Admin::MembersTest < ApplicationSystemTestCase
  include ActionView::Helpers::NumberHelper

  def setup
    @member = create(:verified_member_with_membership, :with_pronunciation)
    sign_in_as_admin
  end

  test "admin can view member's profile" do
    visit admin_member_url(@member)

    assert_content @member.full_name
    assert_content @member.email
    assert_content number_to_phone(@member.phone_number, pattern: /^(\d{0,3})(\d{0,3})(\d{0,4})/, delimiter: " ")&.strip
    assert_content @member.display_pronouns
    assert_content @member.number
    assert_content @member.pronunciation
  end

  test "admin can edit member's profile" do
    visit admin_member_url(@member)

    click_on "Edit Member"
    fill_in "Full name", with: "Updated Name"
    fill_in "Pronunciation", with: "əpˈdeɪtəd neɪm"
    find("label", text: "she/her").click # uncheck
    find("label", text: "he/him").click # check
    click_on "Update Member"

    assert_current_path admin_member_url(@member)
    assert_content "Updated Name"
    assert_content "əpˈdeɪtəd neɪm"
    assert_content "he/him"
    assert_no_content "she/her"
  end

  test "admins can return an item for a member" do
    item = create(:item)
    create(:loan, :checked_out, item:, member: @member)

    visit admin_member_url(@member)

    assert_css "button[id='return-#{item.id}']"
    refute_css "button[disabled][id='return-#{item.id}']"
    refute_text "Undo return"

    click_on "Return"

    assert_text "Undo return"
  end

  test "admins can return an item with accessories for a member" do
    item = create(:item, accessories: ["foo", "bar", rand(100).to_s])
    create(:loan, :checked_out, item:, member: @member)

    visit admin_member_url(@member)

    assert_css "button[disabled][id='return-#{item.id}']"
    refute_text "Undo return"

    item.accessories.each do |accessory|
      find("label", text: accessory).click # check checkbox
    end

    refute_css "button[disabled][id='return-#{item.id}']"

    click_on "Return"

    assert_text "Undo return"
  end

  test "admins can lend an item to a member" do
    item = create(:item)

    visit admin_member_url(@member)

    refute_css "#return-#{item.id}"

    fill_in "Enter an item's number to loan it to this member", with: item.number

    click_on "Lookup"

    assert_text item.name

    click_on "Lend"

    assert_css "#return-#{item.id}"
  end

  test "admins can lend an item with accessories to a member" do
    item = create(:item, accessories: ["foo", "bar", rand(100).to_s])

    visit admin_member_url(@member)

    refute_text "Renew All"

    fill_in "Enter an item's number to loan it to this member", with: item.number

    click_on "Lookup"

    assert_text item.name
    assert_css "#lend-#{item.id}[disabled]"

    item.accessories.each do |accessory|
      find("label", text: accessory).click # check checkbox
    end

    refute_css "#lend-#{item.id}[disabled]"

    click_on "Lend"

    assert_text "Renew All"
  end
end

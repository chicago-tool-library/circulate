require "application_system_test_case"

class CheckInCheckOutTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def setup
    @user = FactoryBot.create(:user)
    login_as(@user, :scope => :user)
  end

  test "checks out items to member" do
    @item = create(:item)
    @member = create(:active_member)

    visit admin_member_url(@member)

    fill_in :loan_item_number, with: @item.number
    click_on "Checkout"
    within ".member-active-loans" do
      assert_text @item.name
    end
  end

  test "returns loaned item" do
    @item = create(:item)
    @member = create(:active_member)
    create(:loan, item: @item, member: @member)

    visit admin_member_url(@member)

    within ".member-active-loans" do
      assert_text @item.name
      click_on "Return"
    end

    refute_selector ".member-active-loans"

    within ".member-recent-loans" do
      assert_text @item.name
    end
  end
end

require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = create(:member)
    @loan1 = create(:loan, member: @member)
    @loan2 = create(:loan)
  end

  test "should return success" do
    get member_loans_url
    assert_response :success
  end

  test "should load the member's loans" do
    get member_loans_url
    assert_equal @controller.instance_variable_get(:@loans), [@loan1]
  end
end

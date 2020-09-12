require 'test_helper'

class MemberProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = create(:verified_member_with_membership)
  end

  test "member views profile" do
    get member_profile_url
    assert_response :success
  end
end

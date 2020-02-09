require "test_helper"

class RenewalRequestsControllerTest < ActionDispatch::IntegrationTest
  test "displays the renewal page for a member" do
    member = create(:member)
    renewal_request = RenewalRequest.new(member_id: member.id)

    get renewal_request_path(renewal_request.encrypt)

    assert_equal 200, response.status
    assert_includes response.body, member.email
  end

  test "handles an invalid renewal request" do
    get renewal_request_path("garbage in")

    assert_equal 404, response.status
  end

  test "handles an expired renewal request" do
    renewal_request = RenewalRequest.new(member_id: 123, expires_at: 1.minute.ago)
    get renewal_request_path(renewal_request.encrypt)

    assert_equal 404, response.status
  end
end

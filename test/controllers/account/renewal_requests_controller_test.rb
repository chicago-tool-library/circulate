require "test_helper"

class RenewalRequestsControllerTest < ActionDispatch::IntegrationTest
  test "displays the renewal page for a member" do
    member = create(:member)
    retriever = MemberRetriever.new(member_id: member.id)

    get new_account_renewal_request_path(retriever.encrypt)

    assert_equal 200, response.status
    assert_includes response.body, member.email
  end

  test "renews valid selections"

  test "handles validation errors"

  test "handles an invalid retriever" do
    get new_account_renewal_request_path("garbage in")

    assert_equal 404, response.status
  end

  test "handles an expired retriever" do
    retriever = MemberRetriever.new(member_id: 123, expires_at: 1.minute.ago)
    get new_account_renewal_request_path(retriever.encrypt)

    assert_equal 410, response.status
    assert_includes response.body, "link has expired"
  end
end

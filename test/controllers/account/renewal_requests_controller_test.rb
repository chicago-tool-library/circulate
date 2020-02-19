require "test_helper"

class RenewalRequestsControllerTest < ActionDispatch::IntegrationTest
  test "displays the renewal page for a member" do
    member = create(:member)
    retriever = MemberRetriever.new(member_id: member.id)

    get new_account_member_renewal_request_path(retriever.encrypt)

    assert_equal 200, response.status
    assert_includes response.body, member.email
  end

  test "renews valid selections" do
    member = create(:member)
    retriever = MemberRetriever.new(member_id: member.id)
    loan = create(:loan, member: member)

    post account_member_renewal_requests_path(retriever.encrypt),
      params: {renewal_request: {loan_ids: ["", loan.id.to_s]}}

    assert_equal 302, response.status

    loan.reload.renewals.size == 1
  end

  test "handles validation errors" do
    member = create(:member)
    retriever = MemberRetriever.new(member_id: member.id)
    loan = create(:loan, member: member)

    post account_member_renewal_requests_path(retriever.encrypt),
      params: {renewal_request: {loan_ids: [""]}}

    assert_equal 422, response.status

    loan.reload.renewals.size == 0
  end

  test "handles an invalid retriever" do
    get new_account_member_renewal_request_path("garbage in")

    assert_equal 404, response.status
  end

  test "handles an expired retriever" do
    retriever = MemberRetriever.new(member_id: 123, expires_at: 1.minute.ago)
    get new_account_member_renewal_request_path(retriever.encrypt)

    assert_equal 410, response.status
    assert_includes response.body, "link has expired"
  end
end

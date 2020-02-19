require "test_helper"

class RenewalRequestTest < ActiveSupport::TestCase
  test "renews renewable loans" do
    loan = create(:loan)
    request = RenewalRequest.new(loan_source: loan.member.loans, loan_ids: [loan.id.to_s])

    assert request.valid?
    assert request.commit

    refute_nil loan.reload.ended_at
    assert_size 1, loan.renewals
  end

  test "doesn't renew an unrenewable loan" do
    item = create(:item, borrow_policy: create(:unrenewable_borrow_policy))
    loan = create(:loan, item: item)
    request = RenewalRequest.new(loan_source: loan.member.loans, loan_ids: [loan.id.to_s])

    refute request.valid?
    refute request.commit

    assert_nil loan.reload.ended_at
    assert_size 0, loan.renewals
  end

  test "renews loans using form values" do
    loan = create(:loan)
    request = RenewalRequest.new(
      loan_source: loan.member.loans,
      loan_ids: [loan.id.to_s])

    assert request.valid?
    assert request.commit

    refute_nil loan.reload.ended_at
    assert_size 1, loan.renewals
  end
end

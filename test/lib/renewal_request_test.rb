require "test_helper"

class RenewalRequestTest < ActiveSupport::TestCase
  test "new request generates encrypted value" do
    member_id = 178
    request = RenewalRequest.new(member_id: member_id)

    refute_empty request.encrypt
  end

  test "request is re-hydrated" do
    member_id = 192
    expires_at = 5.days.since
    encrypted = RenewalRequest.new(member_id: member_id, expires_at: expires_at).encrypt

    request = RenewalRequest.decrypt(encrypted)
    assert_instance_of RenewalRequest, request
    assert_equal 192, request.member_id
    assert_equal expires_at, request.expires_at
  end

  test "handles invalid input" do
    assert_nil RenewalRequest.decrypt("not valid encrypted data")
  end
end

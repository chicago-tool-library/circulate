require "test_helper"

class MemberRetrieverTest < ActiveSupport::TestCase
  test "new retriever generates encrypted value" do
    member_id = 178
    retriever = MemberRetriever.new(member_id: member_id)

    refute_empty retriever.encrypt
  end

  test "retriever is re-hydrated" do
    member_id = 192
    expires_at = 5.days.since
    encrypted = MemberRetriever.new(member_id: member_id, expires_at: expires_at).encrypt

    retriever = MemberRetriever.decrypt(encrypted)
    assert_instance_of MemberRetriever, retriever
    assert_equal 192, retriever.member_id
    assert_equal expires_at, retriever.expires_at
  end

  test "handles invalid input" do
    assert_nil MemberRetriever.decrypt("not valid encrypted data")
  end
end

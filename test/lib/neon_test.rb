# frozen_string_literal: true

require "test_helper"

require "json"

class NeonTest < ActiveSupport::TestCase
  test "converts from member to account representation" do
    member = create(:member)
    account = Neon.member_to_account(member)

    assert_equal(account.dig("individualAccount", "primaryContact", "email1"), member.email)
  end
end

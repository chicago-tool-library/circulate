require "test_helper"

module Signup
  class RedemptionTest < ActiveSupport::TestCase
    test "invalid when a code doesn't exist" do
      redemption = Redemption.new(code: "ABCD1234")
      refute redemption.valid?
      assert_equal ["is not a valid code"], redemption.errors[:code]
    end

    test "invalid without a code" do
      redemption = Redemption.new
      refute redemption.valid?
      assert_equal ["is not a valid code"], redemption.errors[:code]
    end

    test "invalid when a code has already been used" do
      membership = create(:membership)
      gift_membership = create(:gift_membership, membership: membership)
      redemption = Redemption.new(code: gift_membership.code.value)
      refute redemption.valid?
      assert_equal ["has already been redeemed"], redemption.errors[:code]
    end

    test "valid when a code has not been used" do
      gift_membership = create(:gift_membership)
      redemption = Redemption.new(code: gift_membership.code.value)
      assert redemption.valid?
      assert gift_membership.id, redemption.gift_membership_id
    end

    test "valid when a formatted code has not been used" do
      gift_membership = create(:gift_membership)
      redemption = Redemption.new(code: gift_membership.code.format)
      assert redemption.valid?
      assert gift_membership.id, redemption.gift_membership_id
    end

    test "valid when extra formatting is added to a formatted code that has not been used" do
      gift_membership = create(:gift_membership)
      code = gift_membership.code.value.scan(/.{4}/).join(" -- ") # ABCD -- 1234
      redemption = Redemption.new(code: " #{code} \n ")
      assert redemption.valid?
      assert gift_membership.id, redemption.gift_membership_id
    end
  end
end

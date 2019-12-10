require 'test_helper'

class GiftMembershipTest < ActiveSupport::TestCase
  test "generates a unique code upon creation" do
    gift_membership = create(:gift_membership)

    assert gift_membership.code.present?
  end
end

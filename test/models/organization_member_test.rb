require "test_helper"

class OrganizationMemberTest < ActiveSupport::TestCase
  test "validations" do
    organization_member = build(:organization_member)
    organization_member.valid?
    assert_equal({}, organization_member.errors.messages)

    organization_member = OrganizationMember.new

    assert organization_member.invalid?
    assert_equal ["can't be blank"], organization_member.errors[:full_name]
    assert_equal ["must exist"], organization_member.errors[:organization]
    assert_equal ["must exist"], organization_member.errors[:user]
  end
end

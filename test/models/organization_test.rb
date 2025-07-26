require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "validations" do
    organization = build(:organization)
    organization.valid?
    assert_equal({}, organization.errors.messages)

    organization = Organization.new

    assert organization.invalid?
    assert_equal ["can't be blank"], organization.errors[:name]

    existing_organization = create(:organization)
    organization = Organization.new(name: existing_organization.name)

    assert organization.invalid?
    assert_equal ["has already been taken"], organization.errors[:name]
  end
end

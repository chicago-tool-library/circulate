require "test_helper"

class MemberTest < ActiveSupport::TestCase
  test "strips no digits from phone number" do
    member = Member.new(phone_number: "(123) 456-7890")
    member.valid?

    assert_equal "1234567890", member.phone_number
  end

  test "allows 606 postal codes" do
    member = FactoryBot.build(:member)

    assert member.valid?
  end

  test "allows 60707 postal code" do
    member = FactoryBot.build(:member, postal_code: "60707")

    assert member.valid?
  end

  test "allows 60827 postal code" do
    member = FactoryBot.build(:member, postal_code: "60827")

    assert member.valid?
  end

  test "rejects non-Chicago postal codes" do
    member = FactoryBot.build(:member, postal_code: "90210")

    assert member.invalid?
    assert member.errors.messages.include?(:postal_code)
    assert member.errors.messages[:postal_code].include?("must be in Chicago")
  end
end

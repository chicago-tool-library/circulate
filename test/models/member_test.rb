require "test_helper"

class MemberTest < ActiveSupport::TestCase
  test "strips no digits from phone number" do
    member = Member.new(phone_number: "(123) 456-7890")
    member.valid?

    assert_equal "1234567890", member.phone_number
  end

  test "finds member by partial email" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("person")
  end

  test "finds member by partial full name" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("B. Wells")
  end

  test "finds member by partial preferred name" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("Ida")
  end

  test "finds member by partial phone number" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("4567")
  end

  test "finds member by formatted phone number" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("(312) 123-4567")
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

  test "member without a user has a role 'member'" do
    member = Member.new

    assert_equal [:member], member.roles
    assert member.member?
  end

  test "member with a user has a default role of 'member'" do
    user = User.new
    member = Member.new(user: user)

    assert_equal [:member], member.roles
    assert member.member?
  end

  test "a 'staff' member has the role 'staff' and 'member'" do
    user = User.new(role: 'staff')
    member = Member.new(user: user)

    assert_equal [:member, :staff], member.roles
    assert member.staff?
  end

  test "an 'admin' member has the role 'admin', 'staff', and 'member'" do
    user = User.new(role: 'admin')
    member = Member.new(user: user)

    assert_equal [:member, :staff, :admin], member.roles
    assert member.admin?
  end
end

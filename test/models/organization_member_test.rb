require "test_helper"

class OrganizationMemberTest < ActiveSupport::TestCase
  [
    :organization_member,
    [:organization_member, :member],
    [:organization_member, :admin]
  ].each do |factory_name|
    test "#{Array(factory_name).join(", ")} is a valid factory/trait" do
      user = build(*factory_name)
      user.valid?
      assert_equal({}, user.errors.messages)
    end
  end

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

  test ".create_with_user creates an organization member and user when valid" do
    organization = create(:organization)
    user_attributes = attributes_for(:user).slice(:email)
    organization_member_attributes = attributes_for(:organization_member).slice(:full_name)

    assert_difference("OrganizationMember.count", 1) do
      assert_difference("User.count", 1) do
        organization_member = OrganizationMember.create_with_user(**user_attributes, **organization_member_attributes, organization:)
        assert organization_member.persisted?
        organization_member.reload
        assert_equal user_attributes[:email], organization_member.user.email
        assert_equal organization_member_attributes[:full_name], organization_member.full_name
        assert_equal organization, organization_member.organization
      end
    end
  end

  test ".create_with_user creates an organization member and associates an existing user" do
    user = create(:user)
    organization = create(:organization)
    organization_member_attributes = attributes_for(:organization_member).slice(:full_name)

    assert_difference("OrganizationMember.count", 1) do
      assert_difference("User.count", 0) do
        organization_member = OrganizationMember.create_with_user(email: user.email.upcase, **organization_member_attributes, organization:)
        assert organization_member.persisted?
        organization_member.reload
        assert_equal user.email, organization_member.user.email
        assert_equal organization_member_attributes[:full_name], organization_member.full_name
        assert_equal organization, organization_member.organization
      end
    end
  end

  test ".create_with_user does not create an organization member or user when organization member is invalid" do
    organization = create(:organization)
    user_attributes = attributes_for(:user).slice(:email)

    assert_difference("OrganizationMember.count", 0) do
      assert_difference("User.count", 0) do
        organization_member = OrganizationMember.create_with_user(**user_attributes, full_name: "", organization:)
        assert organization_member.new_record?
        assert organization_member.user.new_record?
        assert_equal user_attributes[:email], organization_member.user.email
        assert_equal "", organization_member.full_name
        assert_equal organization, organization_member.organization
      end
    end
  end

  test ".create_with_user does not create an organization member or user when user is invalid" do
    organization = create(:organization)
    organization_member_attributes = attributes_for(:organization_member).slice(:full_name)
    email = "invalid email"

    assert_difference("OrganizationMember.count", 0) do
      assert_difference("User.count", 0) do
        organization_member = OrganizationMember.create_with_user(email:, organization:, **organization_member_attributes)
        assert organization_member.new_record?
        assert organization_member.user.new_record?
        assert_equal email, organization_member.user.email
        assert_equal organization_member_attributes[:full_name], organization_member.full_name
        assert_equal organization, organization_member.organization
      end
    end
  end
end

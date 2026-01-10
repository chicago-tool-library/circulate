require "test_helper"

module Admin
  class MembersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @member = create(:member, :with_user)
      @user = create(:admin_user)
      sign_in @user
    end

    test "should get index" do
      get admin_members_url
      assert_response :success
    end

    test "should get new" do
      get new_admin_member_url
      assert_response :success
    end

    test "should create member with associated user and send password reset email" do
      member_attrs = build(:member)
      ActionMailer::Base.deliveries.clear

      assert_difference(["Member.count", "User.count"]) do
        post admin_members_url, params: {
          member: {
            address_verified: member_attrs.address_verified,
            other_id_kind: member_attrs.other_id_kind,
            email: member_attrs.email,
            full_name: member_attrs.full_name,
            id_kind: member_attrs.id_kind,
            bio: member_attrs.bio,
            phone_number: member_attrs.phone_number,
            preferred_name: member_attrs.preferred_name,
            postal_code: "60606",
            address1: member_attrs.address1
          }
        }
      end

      assert_redirected_to admin_member_url(Member.last)

      # Verify the member has an associated user
      member = Member.last
      assert_not_nil member.user
      assert_equal member.email, member.user.email
      assert_equal "member", member.user.role

      # Verify password reset email was sent
      assert_equal 1, ActionMailer::Base.deliveries.count
      mail = ActionMailer::Base.deliveries.last
      assert_equal [member.email], mail.to
      assert_equal "Reset password instructions", mail.subject
    end

    test "should show member" do
      get admin_member_url(@member)
      assert_response :success
    end

    test "should get edit" do
      get edit_admin_member_url(@member)
      assert_response :success
    end

    test "should update member" do
      patch admin_member_url(@member), params: {member: {address_verified: @member.address_verified, other_id_kind: @member.other_id_kind, email: @member.email, full_name: @member.full_name, id_kind: @member.id_kind, notes: @member.notes, phone_number: @member.phone_number, preferred_name: @member.preferred_name, postal_code: "60606"}}
      assert_redirected_to admin_member_url(@member)
    end

    test "should resend member verification email to new unconfirmed user" do
      member = create(:member, user: create(:user, :unconfirmed))
      ActionMailer::Base.deliveries.clear

      post resend_verification_email_admin_member_url(member)
      assert_redirected_to admin_member_url(member)

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.count
      mail = ActionMailer::Base.deliveries.last
      assert_equal [member.user.email], mail.to
      assert_equal "Confirmation instructions", mail.subject
    end

    test "should resend member verification email to previously confirmed user" do
      member = create(:member, user: create(:user, :unconfirmed, unconfirmed_email: "unconfirmed@example.com"))
      ActionMailer::Base.deliveries.clear

      post resend_verification_email_admin_member_url(member)
      assert_redirected_to admin_member_url(member)

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.count
      mail = ActionMailer::Base.deliveries.last
      assert_equal [member.user.unconfirmed_email], mail.to
      assert_equal "Confirmation instructions", mail.subject
    end
  end
end

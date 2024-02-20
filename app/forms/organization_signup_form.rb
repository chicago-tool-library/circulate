# This class encapsulates creating an Organization, OrganizationMember, and
# User record from a single form, as is done by the new org signup flow.
class MemberSignupForm
  include ActiveModel::Model

  ORGANIZATION_ATTRIBUTES = %w[
    name postal_code address1 address2
  ]
  ORGANIZATION_MEMBER_ATTRIBUTES = %w[
    full_name preferred_name email phone_number
    reminders_via_email reminders_via_text receive_newsletter
    volunteer_interest pronouns
  ]
  USER_ATTRIBUTES = %w[password password_confirmation]

  delegate(*ORGANIZATION_ATTRIBUTES, to: :@organization)
  delegate(*USER_ATTRIBUTES, to: :@user)

  def initialize(params)
    @member = Member.new(params.slice(*MEMBER_ATTRIBUTES))
    @user = User.new(params.slice(*USER_ATTRIBUTES))
  end
end

# This class encapsulates creating an Organization, an OrganizationMember, and
# a User record from a single form, as is done by the new organization member
# signup flow.
class OrganizationMemberSignupForm
  include ActiveModel::Model

  MEMBER_ATTRIBUTES = %w[
    full_name preferred_name email
    address1 address2
  ]

  ORGANIZATION_ATTRIBUTES = %w[name website address1 address2]

  USER_ATTRIBUTES = %w[password password_confirmation]

  delegate(*MEMBER_ATTRIBUTES, to: :@member)
  delegate(*ORGANIZATION_ATTRIBUTES, to: :@organization)
  delegate(*USER_ATTRIBUTES, to: :@user)

  def initialize(params)
    @member = OrganizationMember.new(params.slice(*MEMBER_ATTRIBUTES))
    @organization = Organization.new(params.slice(*ORGANIZATION_ATTRIBUTES))
    @user = User.new(params.slice(*USER_ATTRIBUTES))
  end

  def errors
    errs = @member.errors.dup
    errs.merge! @user.errors
    errs
  end

  def member_id
    @member.id
  end

  def save
    ActiveRecord::Base.transaction do
      @user.email = @member.email
      @member.user = @user
      @member.save
      @user.save

      raise ActiveRecord::Rollback unless @user.persisted? && @member.persisted?
      true
    end
  end
end

# This class encapsulates creating an Organization, an OrganizationMember, and
# a User record from a single form, as is done by the new organization member
# signup flow.
class OrganizationMemberSignupForm
  include ActiveModel::Model

  MEMBER_ATTRIBUTES = %w[
    full_name
  ]

  ORGANIZATION_ATTRIBUTES = %w[name website address1 address2]

  USER_ATTRIBUTES = %w[email password password_confirmation]

  delegate(*MEMBER_ATTRIBUTES, to: :@member)
  delegate(*ORGANIZATION_ATTRIBUTES, to: :@organization)
  delegate(*USER_ATTRIBUTES, to: :@user)

  def initialize(params = {})
    @member = OrganizationMember.new(params.slice(*MEMBER_ATTRIBUTES))
    @organization = Organization.new(params.slice(*ORGANIZATION_ATTRIBUTES))
    @user = User.new(params.slice(*USER_ATTRIBUTES))
  end

  def errors
    errs = @member.errors.dup
    errs.merge! @user.errors
    errs.merge! @organization.errors
    errs
  end

  attr_reader :user

  def save
    ActiveRecord::Base.transaction do
      if @organization.save && @user.save
        @member.organization = @organization
        @member.user = @user
        @member.save
      end

      # ensure the form shows user validation errors if the org is itself invalid
      @user.valid?

      raise ActiveRecord::Rollback unless @user.persisted? && @member.persisted? && @organization.persisted?
      true
    end
  end
end

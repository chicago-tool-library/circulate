# This class encapsulates creating both a Member and User record from a single form,
# as is done by the new member signup flow.
class MemberSignupForm
  include ActiveModel::Model

  MEMBER_ATTRIBUTES = %w[
    full_name preferred_name email pronoun custom_pronoun phone_number postal_code
    address1 address2 desires reminders_via_email reminders_via_text receive_newsletter
    volunteer_interest pronouns
  ]

  USER_ATTRIBUTES = %w[password password_confirmation]

  delegate(*MEMBER_ATTRIBUTES, to: :@member)
  delegate(*USER_ATTRIBUTES, to: :@user)

  def initialize(params)
    @member = Member.new(params.slice(*MEMBER_ATTRIBUTES))
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

      raise ActiveRecord::Rollback unless @user.persisted? && @member.persisted?
      true
    end
  end
end

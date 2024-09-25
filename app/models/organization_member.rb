class OrganizationMember < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  # while the canonical list of roles is the "organization_member_role" enum in the
  # database, this enum exists to help display the list of roles
  # elsewhere in the app
  enum :role, {
    admin: "admin",
    member: "member"
  }

  validates :full_name, presence: true

  def self.create_with_user(email:, **organization_member_attributes)
    organization_member = new(organization_member_attributes)
    user = User.find_by_case_insensitive_email(email) || User.new(email:, password: Devise.friendly_token)
    organization_member.user = user

    transaction do
      raise ActiveRecord::Rollback unless user.save
      raise ActiveRecord::Rollback unless organization_member.save
    end

    organization_member
  end
end

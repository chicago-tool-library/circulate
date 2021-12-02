class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :lockable, :timeoutable, :trackable, :validatable

  acts_as_tenant :library

  # while the canonical list of roles is the "user_role" enum in the
  # database, this enum exists to help display the list of roles
  # elsewhere in the app
  enum role: {
    member: "member",
    staff: "staff",
    admin: "admin",
    super_admin: "super_admin"
  }

  belongs_to :member, optional: true

  scope :by_creation_date, -> { order(created_at: :asc) }

  def roles
    case role
    when "member"
      [:member]
    when "staff"
      [:member, :staff]
    when "admin"
      [:member, :staff, :admin]
    when "super_admin"
      [:member, :staff, :admin, :super_admin]
    else
      []
    end
  end

  def has_role?(other)
    roles.include?(other.to_sym)
  end

  def self.serialize_from_session(key, salt)
    record = eager_load(:member).find_by(id: key)
    record if record && record.authenticatable_salt == salt
  end
end

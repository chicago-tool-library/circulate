class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :lockable, :timeoutable, :trackable

  validates_presence_of :email, if: :email_required?
  validates_format_of :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?
  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of :password, within: Devise.password_length, allow_blank: true

  # while the canonical list of roles is the "user_role" enum in the
  # database, this enum exists to help display the list of roles
  # elsewhere in the app
  enum role: {
    member: "member",
    staff: "staff",
    admin: "admin"
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
    else
      []
    end
  end

  def self.serialize_from_session(key, salt)
    record = eager_load(:member).find_by(id: key)
    record if record && record.authenticatable_salt == salt
  end

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end
end

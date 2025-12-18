class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :lockable, :timeoutable, :trackable, :confirmable,
    reconfirmable: true

  extend Devise::Models::Validatable::ClassMethods

  acts_as_tenant :library

  # while the canonical list of roles is the "user_role" enum in the
  # database, this enum exists to help display the list of roles
  # elsewhere in the app
  enum :role, {
    member: "member",
    staff: "staff",
    admin: "admin",
    super_admin: "super_admin"
  }

  has_one :member

  # Adapted from https://github.com/heartcombo/devise/blob/main/lib/devise/models/validatable.rb
  # so we can scope email uniqueness to library_id
  validates :email, presence: {if: :email_required?}
  validates :email, uniqueness: {allow_blank: true, case_sensitive: false, if: :devise_will_save_change_to_email?, scope: :library_id}
  validates :email, format: {with: email_regexp, allow_blank: true, if: :devise_will_save_change_to_email?}
  validates :password, presence: {if: :password_required?}
  validates :password, confirmation: {if: :password_required?}
  validates :password, length: {within: password_length, allow_blank: true}

  scope :by_creation_date, -> { order(created_at: :asc) }

  def self.find_by_case_insensitive_email(email)
    find_by(arel_table[:email].lower.eq(email.downcase))
  end

  def self.generate_temporary_password
    Devise.friendly_token.first(6)
  end

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

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end
end

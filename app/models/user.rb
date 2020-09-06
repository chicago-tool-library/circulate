class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, # :registerable,
    :recoverable, :rememberable, :validatable,
    :lockable, :timeoutable, :trackable

  # while the canonical list of roles is the "user_role" enum in the
  # database, this enum exists to help display the list of roles
  # elsewhere in the app
  enum role: {
    member: "member",
    staff: "staff",
    admin: "admin",
  }

  def roles
    case role
    when 'member'
      [:member]
    when 'staff'
      [:member, :staff]
    when 'admin'
      [:member, :staff, :admin]
    else
      []
    end
  end

  def self.serialize_from_session(key, salt)
    record = eager_load(:member).find_by(id: key)
    record if record && record.authenticatable_salt == salt
  end

  belongs_to :member, optional: true

  scope :by_creation_date, -> { order(created_at: :asc) }
end

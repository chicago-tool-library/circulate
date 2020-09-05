class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, # :registerable,
    :recoverable, :rememberable, :validatable,
    :lockable, :timeoutable, :trackable

  enum role: {
    staff: "staff",
    admin: "admin"
  }

  belongs_to :member, optional: true

  scope :by_creation_date, -> { order(created_at: :asc) }
end

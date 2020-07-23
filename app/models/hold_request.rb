class HoldRequest < ApplicationRecord
  has_many :hold_request_items, dependent: :destroy
  has_many :items, through: :hold_request_items
  belongs_to :member

  attr_accessor :postal_code

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email"}
  validates :postal_code, length: {is: 5, blank: false, message: "must be 5 digits"}
  validates :event_id, presence: {message: "must select a time slot"}

  before_validation :set_member
  after_validation :add_member_errors

  private

  def set_member
    if email.present? && postal_code.present?
      member = Member.status_pending.or(Member.status_verified).find_by(email: email, postal_code: postal_code)
      self.member = member if member
    end
  end

  def add_member_errors
    if errors.keys == [:member]
      errors.add(:email, "no account for this email and zipcode")
      errors.add(:postal_code, "")
    end
  end
end

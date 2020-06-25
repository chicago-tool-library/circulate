class Member < ApplicationRecord
  has_many :acceptances, class_name: "AgreementAcceptance", dependent: :destroy
  has_many :adjustments

  has_many :loans, dependent: :destroy
  has_many :loan_summaries

  has_many :holds, dependent: :destroy

  has_many :memberships, dependent: :destroy
  has_one :active_membership, -> { merge(Membership.active) }, class_name: "Membership"

  enum pronoun: [:"he/him", :"she/her", :"they/them", :custom_pronoun]
  enum id_kind: [:drivers_license, :state_id, :city_key, :student_id, :employee_id, :other_id_kind]
  enum status: [:pending, :verified, :suspended, :deactivated], _prefix: true

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email"}
  validates :full_name, presence: true
  validates :phone_number, length: {is: 10, blank: false, message: "must be 10 digits"}
  validates :custom_pronoun, presence: true, if: proc { |m| m.custom_pronoun? }
  validates :address1, presence: true, on: :create
  validates :city, presence: true
  validates :region, presence: true
  validates :postal_code, length: {is: 5, blank: false, message: "must be 5 digits"}

  scope :matching, ->(query) {
    where("email ILIKE ? OR full_name ILIKE ? OR preferred_name ILIKE ? OR phone_number LIKE ?",
      "#{query}%", "%#{query}%", "%#{query}%", "%#{query}")
  }
  scope :verified, -> { where(status: statuses[:verified]) }
  scope :open, -> { where(status: statuses.slice(:pending, :verified).values) }
  scope :closed, -> { where(status: statuses.slice(:suspended, :deactivated).values) }
  scope :active_on, ->(date) { joins(:loan_summaries).merge(LoanSummary.active_on(date)).distinct }
  scope :with_outstanding_items, ->(date) { joins(:loan_summaries).merge(LoanSummary.overdue_as_of(date)).distinct }
  scope :volunteer, -> { where(volunteer_interest: true) }

  scope :by_full_name, -> { order(full_name: :desc) }

  before_validation :strip_phone_number
  before_validation :set_default_address_fields

  def assign_number
    self.number = (self.class.maximum(:number) || 0) + 1
  end

  def account_balance
    Money.new(adjustments.calculate("SUM", :amount_cents))
  end

  def borrow?
    active_membership && address_verified
  end

  private

  def strip_phone_number
    self.phone_number = phone_number.gsub(/\D/, "")
  end

  def set_default_address_fields
    self.city ||= "Chicago"
    self.region ||= "IL"
  end
end

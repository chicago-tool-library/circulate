class Member < ApplicationRecord
  has_many :acceptances, class_name: "AgreementAcceptance", dependent: :destroy
  has_many :adjustments

  has_many :loans, dependent: :destroy
  has_many :active_loans, -> { includes(:item).merge(Loan.active) }, class_name: "Loan"
  has_many :loan_summaries

  has_many :memberships, dependent: :destroy
  has_one :active_membership, -> { merge(Membership.active) }, class_name: "Membership"

  enum pronoun: [:"he/him", :"she/her", :"they/them", :custom_pronoun]
  enum id_kind: [:drivers_license, :state_id, :city_key, :student_id, :employee_id, :other_id_kind]
  enum status: [:pending, :active, :suspended, :deactivated], _prefix: true

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email"}
  validates :full_name, presence: true
  validates :phone_number, length: {is: 10, blank: false, message: "must be 10 digits"}
  validates :custom_pronoun, presence: true, if: proc { |m| m.custom_pronoun? }
  validates :postal_code, length: {is: 5, blank: false, message: "must be 5 digits"}

  scope :matching, ->(query) { where("email = ? OR full_name ILIKE ?", query, "%#{query}%") }
  scope :open, -> { where(status: statuses.slice(:pending, :active).values)}
  scope :closed, -> { where(status: statuses.slice(:suspended, :deactivated).values)}
  scope :active_on, ->(date) { joins(:loans).merge(Loan.updated_on(date))}

  before_validation :strip_phone_number

  def account_balance
    @account_balance ||= Money.new(adjustments.calculate("SUM", :amount_cents))
  end

  private

  def strip_phone_number
    self.phone_number = phone_number.gsub(/\D/, "")
  end
end

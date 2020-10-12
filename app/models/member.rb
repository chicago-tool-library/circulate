class Member < ApplicationRecord
  has_many :acceptances, class_name: "AgreementAcceptance", dependent: :destroy
  has_many :adjustments

  has_many :loans, dependent: :destroy
  has_many :checked_out_loans, -> { checked_out }, class_name: "Loan"
  has_many :appointments, dependent: :destroy
  has_many :loan_summaries

  has_many :holds, dependent: :destroy
  has_many :active_holds, -> { active }, class_name: "Hold"

  has_many :memberships, dependent: :destroy
  has_one :active_membership, -> { merge(Membership.active) }, class_name: "Membership"
  has_one :user # what to do if member record deleted?

  PRONOUNS = ["he/him", "she/her", "they/them"]
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
  validate :postal_code_must_be_in_chicago

  scope :matching, ->(query) {
    where("email ILIKE ? OR full_name ILIKE ? OR preferred_name ILIKE ? OR phone_number LIKE ? OR phone_number = ?",
      "#{query}%", "%#{query}%", "%#{query}%", "%#{query}", query.scan(/\d/).join.to_s)
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

  def roles
    user ? user.roles : [:member]
  end

  def member?
    roles.include? :member
  end

  def staff?
    roles.include? :staff
  end

  def admin?
    roles.include? :admin
  end

  def assign_number
    self.number = (self.class.maximum(:number) || 0) + 1
  end

  def account_balance
    Money.new(adjustments.calculate("SUM", :amount_cents))
  end

  def borrow?
    active_membership && address_verified
  end

  def self.pronoun_list
    PRONOUNS
  end

  def display_pronouns
    pronouns.join(", ")
  end

  private

  def strip_phone_number
    self.phone_number = phone_number.gsub(/\D/, "")
  end

  def set_default_address_fields
    self.city ||= "Chicago"
    self.region ||= "IL"
  end

  def postal_code_must_be_in_chicago
    return true if postal_code.nil?

    unless ["60707", "60827"].include?(postal_code) || postal_code.starts_with?("606")
      errors.add :postal_code, "must be in Chicago"
    end
  end
end

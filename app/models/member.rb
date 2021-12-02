class Member < ApplicationRecord
  has_many :acceptances, class_name: "AgreementAcceptance", dependent: :destroy
  has_many :adjustments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_many :loans, dependent: :destroy
  has_many :checked_out_loans, -> { checked_out }, class_name: "Loan"
  has_many :appointments, dependent: :destroy
  has_many :loan_summaries

  has_many :holds, dependent: :destroy
  has_many :active_holds, -> { active }, class_name: "Hold"
  has_many :inactive_holds, -> { inactive }, class_name: "Hold"

  has_many :memberships, dependent: :destroy
  has_one :active_membership, -> { merge(Membership.active) }, class_name: "Membership"
  has_one :pending_membership, -> { merge(Membership.pending) }, class_name: "Membership"
  has_one :last_membership, -> { order("ended_at DESC NULLS FIRST") }, class_name: "Membership"

  has_one :user, dependent: :destroy
  has_many :notes, as: :notable

  PRONOUNS = ["he/him", "she/her", "they/them"]
  enum id_kind: [:drivers_license, :state_id, :city_key, :student_id, :employee_id, :other_id_kind]
  enum status: [:pending, :verified, :suspended, :deactivated], _prefix: true

  validates :email,
    format: {with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email"},
    uniqueness: {conditions: -> { where.not(status: "deactivated") }}
  validates :full_name, presence: true
  validates :phone_number, length: {is: 10, blank: false, message: "must be 10 digits"}
  validates :address1, presence: true
  validates :city, presence: true
  validates :region, presence: true
  validates :postal_code, length: {is: 5, blank: false, message: "must be 5 digits"}
  validate :postal_code_must_be_in_library_service_area

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
  before_validation :downcase_email

  after_save :update_user_email
  after_update :update_neon_crm, if: :can_update_neon_crm?

  acts_as_tenant :library

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

  def super_admin?
    roles.include? :super_admin
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
    pronouns.reject(&:empty?).join(", ")
  end

  def upcoming_appointment_of(schedulable)
    if schedulable.is_a? Hold
      appointments.upcoming.joins(:holds).where(holds: {id: schedulable.id}).first
    elsif schedulable.is_a? Loan
      appointments.upcoming.joins(:loans).where(loans: {id: schedulable.id}).first
    end
  end

  private

  def update_user_email
    user.update_column(:email, email) if user && !user.new_record? # Skip validations
  end

  def update_neon_crm
    NeonMemberJob.perform_async(id)
  end

  def can_update_neon_crm?
    Rails.env.production? && Neon.credentials_for_library(library)
  end

  def strip_phone_number
    self.phone_number = phone_number.gsub(/\D/, "")
  end

  def set_default_address_fields
    self.city ||= library.city
    self.region ||= "IL"
  end

  def downcase_email
    self.email = email.try(:downcase)
  end

  def postal_code_must_be_in_library_service_area
    return unless library && postal_code.present?

    unless library.allows_postal_code?(postal_code)
      errors.add :postal_code, "must be one of: #{library.admissible_postal_codes.join(", ")}"
    end
  end
end

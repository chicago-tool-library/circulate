class Member < ApplicationRecord
  has_many :acceptances, class_name: "AgreementAcceptance", dependent: :destroy
  has_many :adjustments, dependent: :destroy
  has_many :borrow_policy_approvals, dependent: :destroy
  has_many :borrow_policies, through: :borrow_policy_approvals
  has_many :notifications, dependent: :destroy

  has_many :loans, dependent: :destroy
  has_many :checked_out_loans, -> { checked_out }, class_name: "Loan"
  has_many :overdue_loans, -> { overdue }, class_name: "Loan"
  has_many :appointments, dependent: :destroy
  has_many :loan_summaries

  has_many :holds, dependent: :destroy
  has_many :active_holds, -> { active }, class_name: "Hold"
  has_many :inactive_holds, -> { inactive }, class_name: "Hold"

  has_many :memberships, dependent: :destroy
  has_one :active_membership, -> { merge(Membership.active) }, class_name: "Membership"
  has_one :pending_membership, -> { merge(Membership.pending) }, class_name: "Membership"
  has_one :last_membership, -> { order("ended_at DESC NULLS FIRST") }, class_name: "Membership"

  belongs_to :user, optional: true
  has_many :notes, as: :notable
  has_many :for_later_list_items, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :for_later_listed_items, through: :for_later_list_items, source: :item

  PRONOUNS = ["he/him", "she/her", "they/them"]
  enum :id_kind, {drivers_license: 0, state_id: 1, city_key: 2, student_id: 3, employee_id: 4, other_id_kind: 5}
  enum :status, {pending: 0, verified: 1, suspended: 2, deactivated: 3}, prefix: true

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

  scope :for_export, -> {
    joins("LEFT OUTER JOIN (#{Membership.for_export.to_sql}) AS maby ON members.id = maby.member_id").select("members.*, maby.*")
      .order("id ASC")
  }

  before_validation :strip_phone_number
  before_validation :set_default_address_fields
  before_validation :downcase_email

  after_update :update_neon_crm, if: :can_update_neon_crm?
  after_update :update_user_email
  after_save :send_welcome_text, if: -> {
    reminders_via_text? && (saved_change_to_phone_number? || saved_change_to_reminders_via_text?)
  }

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

  def naively_split_name
    name_parts = member.full_name.split(" ")
    if name_parts.size == 2
      [name_parts[0], "", name_parts[1]]
    else
      [name_parts[0], name_parts[1], name_parts[2..]&.join(" ")]
    end
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

  def canonical_phone_number
    "+1#{phone_number}"
  end

  def membership_status
    if active_membership
      "active"
    elsif pending_membership
      "pending"
    elsif last_membership
      "ended"
    else
      "no membership"
    end
  end

  private

  def send_welcome_text
    MemberTexter.new(self).welcome_info
  rescue => e
    Rails.logger.error("Error notifying member #{id}: #{e}")
    Appsignal.send_error(e)
  end

  def update_user_email
    if user && user.email != email
      user.update_column(:unconfirmed_email, email)
    end
  end

  def update_neon_crm
    NeonMemberJob.perform_later(id)
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

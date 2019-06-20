class Member < ApplicationRecord
  has_many :loans, dependent: :destroy
  has_many :active_loans, -> { includes(:item).merge(Loan.active) }, class_name: "Loan"
  has_many :adjustments

  enum pronoun: [:"he/him", :"she/her", :"they/them", :custom_pronoun]
  enum id_kind: [:drivers_license, :state_id, :city_key, :student_id, :employee_id, :other_id_kind]
  enum status: [:pending, :active, :suspended], _prefix: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email" }

  validates :full_name, presence: true
  validates :phone_number, length: { is: 10, blank: false, message: "must be 10 digits" }
  validates :id_kind, presence: true
  validates :custom_pronoun, presence: true, if: Proc.new {|m| m.custom_pronoun?}
  validates :other_id_kind, presence: true, if: Proc.new {|m| m.other_id_kind?}

  scope :matching, ->(query){ where("email = ? OR full_name ILIKE ?", query, "%#{query}%")}

  before_validation :strip_phone_number

  def account_balance
    @account_balance ||= Money.new(adjustments.calculate("SUM", :amount_cents))
  end

  private

  def strip_phone_number
    self.phone_number = phone_number.gsub(/\D/, "")
  end
end
class Member < ApplicationRecord
  validates :email, presence: true
  validates :full_name, presence: true
  validates :phone_number, presence: true
  validates :id_kind, presence: true
  validates :custom_pronoun, presence: true, if: Proc.new {|m| m.custom_pronoun?}
  validates :other_id_kind, presence: true, if: Proc.new {|m| m.other_id_kind?}

  enum pronoun: [:"he/him", :"she/her", :"they/their", :custom_pronoun]
  enum id_kind: [:drivers_license, :state_id, :city_key, :student_id, :employee_id, :other_id_kind]
  enum status: [:pending, :active, :suspended], _prefix: true

  has_many :loans, dependent: :destroy
  has_many :active_loans, -> { includes(:item).merge(Loan.active) }, class_name: "Loan"
end

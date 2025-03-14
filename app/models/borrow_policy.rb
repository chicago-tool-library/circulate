class BorrowPolicy < ApplicationRecord
  monetize :fine_cents, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: 10
  }

  has_many :borrow_policy_approvals, dependent: :destroy

  validates :name,
    presence: true, uniqueness: {scope: :library_id, case_sensitive: false}
  validates :duration,
    numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than: 365}
  validates :fine_period,
    numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100}
  validates :renewal_limit,
    numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 52}
  validates :code, inclusion: {in: "A".."ZZ", message: "must be 1 or 2 letters from A to ZZ"}, uniqueness: {scope: :library_id}

  validate :require_consumables_to_not_be_uniquely_numbered

  scope :alpha_by_code, -> { order("code ASC") }
  scope :not_uniquely_numbered, -> { where(uniquely_numbered: false) }

  acts_as_tenant :library

  has_rich_text :rules

  def self.default
    where(default: true).first
  end

  def self.not_uniquely_numbered_ids
    not_uniquely_numbered.pluck(:id)
  end

  def complete_name
    "#{name} (#{code})"
  end

  def allow_multiple_holds_per_member?
    !allow_one_holds_per_member?
  end

  def allow_one_holds_per_member?
    uniquely_numbered
  end

  after_save :make_only_default

  private

  def make_only_default
    if default
      self.class.where.not(id: id).update_all(default: false)
    end
  end

  def require_consumables_to_not_be_uniquely_numbered
    if consumable? && uniquely_numbered
      errors.add(:uniquely_numbered, "must not be enabled for consumables")
    end
  end
end

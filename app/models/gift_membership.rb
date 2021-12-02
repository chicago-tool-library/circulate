class GiftMembership < ApplicationRecord
  monetize :amount_cents, numericality: {
    greater_than_or_equal_to: 0
  }

  composed_of :code, class_name: "GiftMembershipCode", mapping: %w[code value], allow_nil: true

  belongs_to :membership, required: false
  validates :purchaser_email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email"}
  validates :purchaser_name, presence: true
  validates :code, presence: true, uniqueness: {scope: :library_id}

  before_validation :set_code, if: ->(gm) { gm.code.blank? }

  acts_as_tenant :library

  def self.unique_code?(code)
    where(code: code.value).count == 0
  end

  def redeem(membership)
    update_attribute(:membership_id, membership.id)
  end

  # This is to work around an incompatibility between using composed_of and the
  # built-in uniqueness validation.
  def read_attribute_for_validation(attr)
    if attr.to_sym == :code
      code.try(:value)
    else
      super
    end
  end

  private

  def set_code
    self.code = find_random_unique_code
  end

  def find_random_unique_code
    5.times do |n|
      code = GiftMembershipCode.random
      return code if self.class.unique_code?(code)
    end
    raise "could not find a unique code"
  end
end

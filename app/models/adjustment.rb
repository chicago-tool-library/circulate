class Adjustment < ApplicationRecord
  monetize :amount_cents

  enum payment_source: {
    cash: "cash",
    square: "square",
  }

  belongs_to :adjustable, polymorphic: true, optional: true
  belongs_to :member

  # validates_presence_of :square_transaction_id, if: ->(a) { a.square? }
  validates_inclusion_of :payment_source, in: payment_sources, if: ->(a) { a.adjustable.blank? }

  def payment?
    adjustable_id.nil?
  end
end

# fine:
# - adjustable_type: Loan

# membership:
# - adjustable_type: Membership

# payment:
# - adjustable_type: nil
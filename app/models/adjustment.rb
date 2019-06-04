class Adjustment < ApplicationRecord
  monetize :amount_cents

  belongs_to :adjustable, polymorphic: true
  belongs_to :member

  enum kind: [:fine]
end

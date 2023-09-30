# frozen_string_literal: true

class MonthlyAdjustment < ApplicationRecord
  self.primary_key = :year # to handle cases where the primary key is added to order clauses

  monetize :amount_cents
  monetize :new_membership_total_cents
  monetize :renewal_membership_total_cents
  monetize :payment_total_cents
  monetize :square_total_cents
  monetize :cash_total_cents

  scope :chronologically, -> { order(:year, :month) }

  def readonly?
    true
  end
end

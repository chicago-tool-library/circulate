# frozen_string_literal: true

module Admin
  class Payment
    include ActiveModel::Model

    def self.payment_sources
      Adjustment.payment_sources.slice("cash", "square")
    end

    attr_accessor :amount_dollars
    attr_accessor :payment_source

    validates_numericality_of :amount_dollars,
      greater_than_or_equal_to: 1, less_than_or_equal_to: 500
    validates_inclusion_of :payment_source, in: payment_sources

    def amount
      Money.new(amount_dollars.to_i * 100)
    end
  end
end

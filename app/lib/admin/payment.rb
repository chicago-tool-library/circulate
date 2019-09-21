module Admin
  class Payment
    include ActiveModel::Model

    attr_accessor :amount_dollars
    attr_accessor :payment_source

    validates_numericality_of :amount_dollars,
      greater_than_or_equal_to: 1, less_than_or_equal_to: 500
    validates_inclusion_of :payment_source, in: Adjustment.payment_sources

    def amount
      Money.new(amount_dollars.to_i * 100)
    end
  end
end

module SquareCheckout
  class FetchedOrder
    def initialize(payload)
      @payload = payload
    end

    def id
      @payload[:id]
    end

    def state
      @payload[:state]
    end

    def version
      @payload[:version]
    end

    def fulfillment
      # Orders created by the Payment link API only have a single fulfillment
      @payload[:fulfillments][0]
    end

    def amount
      @amount ||= extract_amount
    end

    def member_id
      @payload[:metadata][:member_id]&.to_i
    end

    def created_by_circulate?
      @payload[:metadata][:created_by] == "circulate"
    end

    private

    def extract_amount
      amount_money = @payload[:tenders][0][:amount_money]
      raise "non-USD currency is not supported" unless amount_money[:currency] == "USD"
      Money.new(amount_money[:amount])
    end
  end
end

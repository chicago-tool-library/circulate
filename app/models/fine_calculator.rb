class FineCalculator
  def amount(fine:, period:, due_at:, returned_at:)
    if returned_at <= due_at
      Money.new(0)
    else
      periods = (returned_at - due_at) / period.days.to_f
      Money.new(periods.ceil * fine)
    end
  end
end

class NullBorrowPolicy
  def renewal_limit
    0
  end

  def fine
    0
  end

  def fine_period
    7
  end

  def duration
    7
  end

  def member_renewable?
    false
  end
end

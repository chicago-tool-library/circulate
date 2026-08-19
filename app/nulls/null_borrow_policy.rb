class NullBorrowPolicy
  def maximum_items_per_member
    0
  end

  def limit_items_per_member?
    false
  end

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

  def consumable?
    false
  end
end

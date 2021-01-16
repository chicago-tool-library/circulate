class NullItem
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(self.class, nil, "item")
  end

  def image
    NullAttachment.new
  end

  def borrow_policy
    NullBorrowPolicy.new
  end

  def id
    "deleted"
  end

  def to_param
    id
  end

  def complete_number
    "X-0000"
  end

  def name
    "Deleted Item"
  end

  def marked_for_destruction?
    false
  end

  def next_hold
    nil
  end
end

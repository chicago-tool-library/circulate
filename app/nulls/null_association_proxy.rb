# frozen_string_literal: true

class NullAssociationProxy
  def count
    0
  end

  def active
    self
  end
end

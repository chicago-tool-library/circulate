require "active_support/concern"

# ReservableItems and unnumbered ItemPools share a single number space so that a scanned
# number identifies exactly one of them. The database can't enforce uniqueness across both
# tables, so it is checked here.
module ReservableNumbering
  extend ActiveSupport::Concern

  included do
    validate :number_not_used_by_other_reservable
  end

  class_methods do
    def next_reservable_number
      [ReservableItem.maximum(:number), ItemPool.maximum(:number)].compact.max.to_i + 1
    end
  end

  private

  def number_not_used_by_other_reservable
    return if number.blank?

    other_class, description = is_a?(ItemPool) ? [ReservableItem, "a reservable item"] : [ItemPool, "an item pool"]
    if other_class.where(library_id: library_id, number: number).exists?
      errors.add(:number, "is already used by #{description}")
    end
  end
end

require "active_support/concern"

module ItemNumbering
  extend ActiveSupport::Concern

  included do
    before_validation :assign_number, on: :create
    validates :number, presence: true, numericality: {only_integer: true}, uniqueness: {scope: :library}
  end

  class_methods do
    def next_number
      scope = order("number DESC NULLS LAST")
      last_item = scope.limit(1).first
      return 1 unless last_item
      last_item.number.to_i + 1
    end
  end

  def assign_number
    if number.blank?
      self.number = self.class.next_number
    end
  end
end

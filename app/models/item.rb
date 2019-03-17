class Item < ApplicationRecord
  validates :name, presence: true
  validates :number, presence: true, numericality: { only_integer: true },  uniqueness: true

  has_rich_text :description

  before_validation :assign_number, on: :create

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  def self.next_number
    last_item = order("number DESC NULLS LAST").limit(1).first
    return 1 unless last_item
    last_item.number.to_i + 1
  end

  def assign_number
    if number.blank?
      self.number = self.class.next_number
    end
  end
end

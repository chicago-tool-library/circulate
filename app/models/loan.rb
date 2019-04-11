class Loan < ApplicationRecord
  belongs_to :item
  belongs_to :member

  validates :due_at, presence: true

  validates_each :item_id do |record, attr, value|
    if !value
      record.errors.add(attr, "does not exist")
    elsif record.item.active_loan && record.item.active_loan.id != record.id
      record.errors.add(attr, "is already on loan")
    end
  end

  scope :active, -> { where("ended_at IS NULL").includes(:item) }

  def ended?
    ended_at.present?
  end
end

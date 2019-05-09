class Item < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations,
    before_add: :cache_category_ids,
    before_remove: :cache_category_ids
  has_many :loans, dependent: :destroy
  has_one :active_loan, -> { where("ended_at IS NULL").readonly }, class_name: "Loan"

  has_rich_text :description
  has_one_attached :image

  audited

  validates :name, presence: true
  validates :number, presence: true, numericality: { only_integer: true },  uniqueness: true

  before_validation :assign_number, on: :create

  enum status: [:new, :active, :maintence, :retired], _prefix: true

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

  def due_on
    active_loan.due_at.to_date
  end

  def available?
    !active_loan.present?
  end

  private

  def cache_category_ids(category)
    @current_category_ids ||= Categorization.where(item_id: id).pluck(:category_id).sort
  end

  # called when item is created
  def audited_attributes
    super.merge("category_ids" => category_ids.sort)
  end

  # called when item is updated
  def audited_changes
    if @current_category_ids.present? && @current_category_ids != category_ids.sort
      super.merge("category_ids" => [@current_category_ids, category_ids.sort])
    else
      super
    end
  end
end

class Item < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings,
                        before_add: :cache_tag_ids,
                        before_remove: :cache_tag_ids
  has_many :loans, dependent: :destroy
  has_one :active_exclusive_loan, -> { active.exclusive.readonly }, class_name: "Loan"
  belongs_to :borrow_policy

  has_rich_text :description
  has_one_attached :image

  enum status: [:pending, :active, :maintenance, :retired]

  audited

  scope :name_contains, ->(query) { where("name ILIKE ?", "%#{query}%").limit(10).distinct }
  scope :brand_contains, ->(query) { where("brand ILIKE ?", "%#{query}%").limit(10).distinct }
  scope :size_contains, ->(query) { where("size ILIKE ?", "%#{query}%").limit(10).distinct }
  scope :strength_contains, ->(query) { where("strength ILIKE ?", "%#{query}%").limit(10).distinct }

  scope :with_tag, ->(tag) { joins(:tags).merge(tag.items) }

  validates :name, presence: true
  validates :number, presence: true, numericality: {only_integer: true}, uniqueness: true
  validates :status, inclusion: {in: Item.statuses.keys}
  validates :borrow_policy_id, inclusion: {in: ->(item) { BorrowPolicy.pluck(:id) }}

  before_validation :assign_number, on: :create

  def self.next_number(limit=nil)
    item_scope = order("number DESC NULLS LAST")
    if limit
      item_scope = item_scope.where("number <= ?", limit)
    end
    last_item = item_scope.limit(1).first
    return 1 unless last_item
    last_item.number.to_i + 1
  end

  def assign_number
    if number.blank?
      return unless borrow_policy

      if borrow_policy.code == "A"
        self.number = self.class.next_number(999)
      else
        self.number = self.class.next_number
      end
    end
  end

  def due_on
    active_exclusive_loan.due_at.to_date
  end

  def available?
    !active_exclusive_loan.present?
  end

  private

  def cache_tag_ids(tag)
    @current_tag_ids ||= Tagging.where(item_id: id).pluck(:tag_id).sort
  end

  # called when item is created
  def audited_attributes
    super.merge("tag_ids" => tag_ids.sort)
  end

  # called when item is updated
  def audited_changes
    if @current_tag_ids && @current_tag_ids != tag_ids.sort
      super.merge("tag_ids" => [@current_tag_ids, tag_ids.sort])
    else
      super
    end
  end
end

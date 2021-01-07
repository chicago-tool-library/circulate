class Item < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_anything,
    against: {
      name: "A",
      other_names: "B",
      brand: "C",
      size: "D",
      strength: "D"
    },
    using: {tsearch: {prefix: true, dictionary: "english"}}

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations,
                        before_add: :cache_category_ids,
                        before_remove: :cache_category_ids
  has_many :loans, dependent: :nullify
  has_many :holds, dependent: :destroy
  has_many :active_holds, -> { active }, dependent: :destroy, class_name: "Hold"
  has_many :loan_summaries
  has_one :checked_out_exclusive_loan, -> { checked_out.exclusive.readonly }, class_name: "Loan"
  belongs_to :borrow_policy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :attachments, class_name: "ItemAttachment"

  has_rich_text :description
  has_one_attached :image

  enum status: [:pending, :active, :maintenance, :retired]

  enum power_source: {
    solar: "solar",
    gas: "gas",
    air: "air",
    electric_corded: "electric (corded)",
    electric_battery: "electric (battery)"
  }

  audited

  scope :name_contains, ->(query) { where("name ILIKE ?", "%#{query}%").limit(10).distinct }
  scope :number_contains, ->(query) { where("number::text ILIKE ?", "%#{query}%") }
  scope :brand_contains, ->(query) { where("brand ILIKE ?", "#{"%" if query.size > 1}#{query}%").limit(10).distinct }
  scope :size_contains, ->(query) { where("size ILIKE ?", "#{"%" if query.size > 1}#{query}%").limit(10).distinct }
  scope :strength_contains, ->(query) { where("strength ILIKE ?", "#{"%" if query.size > 1}#{query}%").limit(10).distinct }
  scope :listed_publicly, -> { where("status = ? OR status = ?", Item.statuses[:active], Item.statuses[:maintenance]) }
  scope :with_category, ->(category) { joins(:categories).merge(category.items) }
  scope :available, -> { left_outer_joins(:checked_out_exclusive_loan).where(loans: {id: nil}) }
  scope :without_attached_image, -> { left_joins(:image_attachment).where(active_storage_attachments: {record_id: nil}) }
  scope :in_maintenance, -> { where("status = ?", Item.statuses[:maintenance]) }

  scope :by_name, -> { order(name: :asc) }

  validates :name, presence: true
  validates :number, numericality: {only_integer: true}, uniqueness: true
  validates :status, inclusion: {in: Item.statuses.keys}
  validates :power_source, inclusion: {in: Item.power_sources.keys}, allow_blank: true
  validates :borrow_policy_id, inclusion: {in: ->(item) { BorrowPolicy.pluck(:id) }}

  before_validation :assign_number, on: :create
  before_validation :strip_whitespace

  def self.next_number(limit = nil)
    item_scope = order("number DESC NULLS LAST")
    if limit
      item_scope = item_scope.where("number <= ?", limit)
    end
    last_item = item_scope.limit(1).first
    return 1 unless last_item
    last_item.number.to_i + 1
  end

  def self.find_by_complete_number(complete_number)
    code, number = complete_number.split("-")
    joins(:borrow_policy).find_by(borrow_policies: {code: code}, number: number.to_i)
  end

  def assign_number
    if number.blank?
      return unless borrow_policy

      self.number = if borrow_policy.code == "A"
        self.class.next_number(999)
      else
        self.class.next_number
      end
    end
  end

  def due_on
    checked_out_exclusive_loan.due_at.to_date
  end

  def available?
    !checked_out_exclusive_loan.present?
  end

  def complete_number
    [borrow_policy.code, "-", number].join
  end

  def complete_number_and_name
    [complete_number, " — ", name].join
  end

  def holdable?
    available? && active_holds.size == 0
  end

  delegate :allow_multiple_holds_per_member?, to: :borrow_policy
  delegate :allow_one_holds_per_member?, to: :borrow_policy

  private

  def strip_whitespace
    %w[name brand size model serial strength].each do |attr_name|
      value = attributes[attr_name]
      next unless value.present?
      write_attribute attr_name, value.strip
    end
  end

  def cache_category_ids(category)
    @current_category_ids ||= Categorization.where(item_id: id).pluck(:category_id).sort
  end

  # called when item is created
  def audited_attributes
    super.merge("category_ids" => category_ids.sort)
  end

  # called when item is updated
  def audited_changes
    if (@current_category_ids.present? || category_ids.present?) && @current_category_ids != category_ids.sort
      super.merge("category_ids" => [@current_category_ids, category_ids.sort])
    else
      super
    end
  end
end

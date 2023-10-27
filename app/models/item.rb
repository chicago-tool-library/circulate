class Item < ApplicationRecord
  STATUS_NAMES = {
    "pending" => "Pending",
    "active" => "Active",
    "maintenance" => "Maintenance",
    "retired" => "Retired"
  }

  STATUS_DESCRIPTIONS = {
    "pending" => "just acquired; not ready to loan",
    "active" => "available to loan",
    "maintenance" => "undergoing maintenance; do not loan",
    "retired" => "no longer part of our inventory"
  }

  include PgSearch::Model
  pg_search_scope :search_by_anything,
    against: {
      name: "A",
      number: "A",
      other_names: "B",
      brand: "C",
      plain_text_description: "C",
      size: "D",
      strength: "D"
    },
    using: {tsearch: {prefix: true, dictionary: "english"}}

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations,
    before_add: :cache_category_ids,
    before_remove: :cache_category_ids
  has_many :category_nodes, through: :categorizations

  has_many :loans, dependent: :nullify
  has_one :checked_out_exclusive_loan, -> { checked_out.exclusive.readonly }, class_name: "Loan"
  has_many :loan_summaries

  has_many :holds, dependent: :destroy
  has_many :active_holds, -> { active }, dependent: :destroy, class_name: "Hold"

  def next_hold
    active_holds.order(created_at: :asc).first
  end

  belongs_to :borrow_policy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :attachments, class_name: "ItemAttachment", dependent: :destroy

  has_many :tickets, dependent: :destroy
  has_one :last_active_ticket, -> { active.newest_first }, class_name: "Ticket"

  has_rich_text :description
  has_one_attached :image

  enum status: {
    pending: "pending",
    active: "active",
    maintenance: "maintenance",
    retired: "retired"
  }

  enum power_source: {
    solar: "solar",
    gas: "gas",
    air: "air",
    electric_corded: "electric (corded)",
    electric_battery: "electric (battery)"
  }

  audited except: :plain_text_description
  acts_as_tenant :library

  monetize :purchase_price_cents,
    allow_nil: true,
    disable_validation: true

  scope :name_contains, ->(query) { where("name ILIKE ?", "%#{query}%").limit(10).distinct }
  scope :brand_contains, ->(query) { where("brand ILIKE ?", "#{"%" if query.size > 1}#{query}%").limit(10).distinct }
  scope :size_contains, ->(query) { where("size ILIKE ?", "#{"%" if query.size > 1}#{query}%").limit(10).distinct }
  scope :strength_contains, ->(query) { where("strength ILIKE ?", "#{"%" if query.size > 1}#{query}%").limit(10).distinct }
  scope :listed_publicly, -> { where("status = ? OR status = ?", Item.statuses[:active], Item.statuses[:maintenance]) }
  scope :with_category, ->(category) { joins(:categories).merge(category.items) }
  scope :for_category, ->(category) { joins(:categorizations).where(categorizations: {category_id: CategoryNode.find(category.id).tree_ids}).distinct }
  scope :available, -> { left_outer_joins(:checked_out_exclusive_loan).where(loans: {id: nil}) }
  scope :without_attached_image, -> { left_joins(:image_attachment).where(active_storage_attachments: {record_id: nil}) }
  scope :in_maintenance, -> { where(status: Item.statuses.values_at(:maintenance)) }
  scope :without_active_holds, -> { left_outer_joins(:active_holds).where(active_holds: {id: nil}) }
  scope :available_now, -> { available.without_active_holds.where(status: Item.statuses[:active]) }

  scope :by_name, -> { order(name: :asc) }

  validates :name, presence: true
  validates :number, numericality: {only_integer: true}, uniqueness: {scope: :library}
  validates :status, inclusion: {in: Item.statuses.keys}
  validates :power_source, inclusion: {in: Item.power_sources.keys}, allow_blank: true
  validates :borrow_policy_id, inclusion: {in: ->(item) { BorrowPolicy.pluck(:id) }}
  validates :quantity, numericality: {only_integer: true, greater_than_or_equal_to: 0}, if: ->(item) { item.borrow_policy && item.borrow_policy.consumable? }
  validates :url, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL", allow_blank: true}

  before_validation :assign_number, on: :create
  before_validation :strip_whitespace

  before_save :cache_description_as_plain_text
  after_update :clear_holds_if_inactive, :pause_next_hold_if_maintenance

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

  def overdue?
    due_on.past?
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
    active?
  end

  delegate :allow_multiple_holds_per_member?, to: :borrow_policy
  delegate :allow_one_holds_per_member?, to: :borrow_policy

  def tracks_quantity?
    !borrow_policy.uniquely_numbered?
  end

  def decrement_quantity
    self.quantity -= 1
    if quantity == 0
      update!(status: "retired", audit_comment: "Quantity exhausted")
    else
      without_auditing do
        save!
      end
    end
  end

  def increment_quantity
    self.quantity += 1
    if quantity == 1
      update!(status: "active", audit_comment: "Quantity restored")
    else
      without_auditing do
        save!
      end
    end
  end

  private

  def cache_description_as_plain_text
    self.plain_text_description = description.to_plain_text
  end

  def strip_whitespace
    %w[name brand size model serial strength].each do |attr_name|
      value = attributes[attr_name]
      next unless value.present?
      write_attribute attr_name, value.strip
    end
  end

  def clear_holds_if_inactive
    if saved_change_to_status? && status == Item.statuses[:retired]
      active_holds.update_all(ended_at: Time.current)
    end
  end

  def pause_next_hold_if_maintenance
    if saved_change_to_status? && status == Item.statuses[:maintenance]
      next_hold&.update_columns(started_at: nil, expires_at: nil)
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
    unless @current_category_ids.present?
      cache_category_ids(nil)
    end
    if (@current_category_ids.present? || category_ids.present?) && @current_category_ids != category_ids.sort
      super.merge("category_ids" => [@current_category_ids, category_ids.sort])
    else
      super
    end
  end
end

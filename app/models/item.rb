class Item < ApplicationRecord
  include ItemCategorization
  include ItemStatuses
  include ItemNumbering

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

  has_rich_text :description

  enum :power_source, {
    solar: "solar",
    gas: "gas",
    air: "air",
    electric_corded: "electric (corded)",
    electric_battery: "electric (battery)"
  }

  validates :power_source, inclusion: {in: power_sources.keys}, allow_blank: true

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

  has_one_attached :image

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
  scope :without_active_holds, -> { where.missing(:active_holds) }
  scope :available_now, -> { available.without_active_holds.where(status: Item.statuses[:active]) }
  scope :holdable, -> { active.and(holds_enabled) }
  scope :holds_enabled, -> { where(holds_enabled: true) }
  scope :missing, -> { where(status: Item.statuses[:missing]) }
  scope :does_not_require_approval, -> { joins(:borrow_policy).where(borrow_policy: {requires_approval: false}) }

  scope :by_name, -> { order(name: :asc) }

  scope :search_and_order_by_availability, ->(query) {
    # allow searching for all number formats, e.g., "B-1234" -> "1234", or "B1234" -> "1234"
    processed_query = (query =~ /^[A-Z]-?(\d+)$/i) ? $1 : query
    item_scope = search_by_anything(processed_query)
      .with_pg_search_rank
      .with(active_hold_counts: Hold.active.group(:item_id).select(:item_id, "COUNT(*) as active_hold_count"))
      .joins(
        "LEFT JOIN active_hold_counts ON active_hold_counts.item_id = items.id"
      )
      .left_joins(:checked_out_exclusive_loan)
      .left_joins(:borrow_policy)

    items = arel_table
    search_priority = Arel::Nodes::Case
      .new(items[:status])
      .when("active").then(
        Arel::Nodes::Case.new
        .when(Loan.arel_table[:id].not_eq(nil)).then(
          Arel::Nodes::Case.new
          .when(Loan.arel_table[:due_at].lt(Time.current)).then(4).else(3)
        )
        .when(
          Arel::Nodes::And.new([
            BorrowPolicy.arel_table[:uniquely_numbered],
            Arel::Nodes::SqlLiteral.new("active_hold_counts.item_id IS NOT NULL")
          ])
        ).then(2)
        .else(1)
      )
      .when("maintenance").then(5)
      .else(6)
      .as("search_priority")

    item_scope.select(
      "#{item_scope.pg_search_rank_table_alias}.rank",
      "items.*",
      search_priority
    ).reorder("#{item_scope.pg_search_rank_table_alias}.rank desc", "search_priority")
  }

  validates :name, presence: true
  validates :borrow_policy_id, inclusion: {in: ->(item) { BorrowPolicy.pluck(:id) }}
  validates :url, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL", allow_blank: true}
  validates :quantity, numericality: {only_integer: true, greater_than_or_equal_to: 0}, if: ->(item) { item.borrow_policy && item.borrow_policy.consumable? }

  before_validation :strip_whitespace

  before_save :cache_description_as_plain_text
  after_update :clear_holds_if_inactive, :pause_next_hold_if_maintenance

  def self.ransackable_attributes(auth_object = nil)
    %w[number name status]
  end

  def self.find_by_complete_number(complete_number)
    code, number = complete_number.split("-")
    joins(:borrow_policy).find_by(borrow_policies: {code: code}, number: number.to_i)
  end

  def due_on
    checked_out_exclusive_loan.due_at.to_date
  end

  def overdue?
    due_on.past?
  end

  def available?
    checked_out_exclusive_loan.blank?
  end

  def complete_number
    [borrow_policy.code, "-", number].join
  end

  def complete_number_and_name
    [complete_number, " — ", name].join
  end

  def holdable?
    active? && holds_enabled
  end

  def holds_enabled_status
    holds_enabled ? "enabled" : "disabled"
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

  def accessories_text
    accessories.join("\n")
  end

  def accessories_text=(value)
    self.accessories = if value.present?
      value.split(/\s*\n\s*/)
    else
      []
    end
  end

  private

  def cache_description_as_plain_text
    self.plain_text_description = description.to_plain_text
  end

  def strip_whitespace
    %w[name brand size model serial strength].each do |attr_name|
      value = attributes[attr_name]
      next if value.blank?
      self[attr_name] = value.strip
    end
  end

  def clear_holds_if_inactive
    return unless saved_change_to_status? && status == Item.statuses[:retired]

    # find any appointments for this item and cancel them, if the appointment has no more items
    next_hold&.remove_from_appointment!
    # updates all holds without running callbacks
    active_holds.update_all(ended_at: Time.current)
  end

  def pause_next_hold_if_maintenance
    if saved_change_to_status? && status == Item.statuses[:maintenance]
      next_hold&.update_columns(started_at: nil, expires_at: nil)
      next_hold&.remove_from_appointment!
    end
  end

  def cache_category_ids(category)
    @current_category_ids ||= Categorization.where(categorized_id: id).pluck(:category_id).sort
  end

  # called when item is created
  def audited_attributes
    super.merge("category_ids" => category_ids.sort)
  end

  # called when item is updated
  def audited_changes(**args)
    if @current_category_ids.blank?
      cache_category_ids(nil)
    end
    if (@current_category_ids.present? || category_ids.present?) && @current_category_ids != category_ids.sort
      super.merge("category_ids" => [@current_category_ids, category_ids.sort])
    else
      super
    end
  end
end

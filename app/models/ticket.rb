class Ticket < ApplicationRecord
  STATUS_NAMES = {
    "assess" => "Assess",
    "repairing" => "Repair in Progress",
    "parts" => "Parts on Order",
    "resolved" => "Resolved",
    "retired" => "Retired"
  }

  STATUS_DESCRIPTIONS = {
    "assess" => "newly created; needs examination by maintenance team",
    "parts" => nil,
    "repairing" => nil,
    "resolved" => "the problem has been fixed",
    "retired" => "removed from inventory"
  }

  enum :status, {
    assess: "assess",
    parts: "parts",
    repairing: "repairing",
    resolved: "resolved",
    retired: "retired"
  }

  belongs_to :item
  belongs_to :creator, class_name: "User"
  has_many :ticket_updates, dependent: :destroy
  has_one :latest_ticket_update, -> { newest_first }, class_name: "TicketUpdate"

  has_rich_text :body

  acts_as_taggable_on :tags

  validates :title, presence: true
  validates :status, inclusion: {in: Ticket.statuses.keys}

  audited except: :tag_list
  acts_as_tenant :library

  scope :active, -> { where(status: Ticket.statuses.values_at(:assess, :parts, :repairing)) }
  scope :newest_first, -> { order(created_at: :desc) }
  # used for filtering--if no tags are selected, don't filter by tags
  scope :has_tags, ->(tags) do  
    if tags.present? 
      tagged_with(tags) 
    else
      all
    end
  end 

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at updated_at title status]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[item]
  end
end

# frozen_string_literal: true

class Ticket < ApplicationRecord
  STATUS_NAMES = {
    "assess" => "Assess",
    "repairing" => "Repair in Progress",
    "parts" => "Parts on Order",
    "resolved" => "Resolved"
  }

  STATUS_DESCRIPTIONS = {
    "assess" => "newly created; needs examination by maintenance team",
    "parts" => nil,
    "repairing" => nil,
    "resolved" => "the problem has been fixed"
  }

  enum status: {
    assess: "assess",
    parts: "parts",
    repairing: "repairing",
    resolved: "resolved"
  }

  belongs_to :item
  belongs_to :creator, class_name: "User"
  has_many :ticket_updates, dependent: :destroy
  has_one :latest_ticket_update, -> { newest_first }, class_name: "TicketUpdate"

  has_rich_text :body

  validates :title, presence: true
  validates :status, inclusion: { in: Ticket.statuses.keys }

  audited
  acts_as_tenant :library

  scope :active, -> { where(status: Ticket.statuses.values_at(:assess, :parts, :repairing)) }
  scope :newest_first, -> { order(created_at: :desc) }
end

class Hold < ApplicationRecord
  belongs_to :member
  belongs_to :item, counter_cache: true
  belongs_to :creator, class_name: "User"
  belongs_to :loan, required: false

  validate :can_create_hold_for_memember_on_item

  scope :active, -> { where("ended_at IS NULL") }
  scope :ended, -> { where("ended_at IS NOT NULL") }

  def self.active_hold_count_for_item(item)
    active.where(item: item).count
  end

  def lend(loan, now: Time.current)
    update!(
      loan: loan,
      ended_at: now
    )
  end

  def previous_active_holds
    Hold.active.where("created_at < ?", created_at).where(item: item).where.not(member: member).order(:ended_at).to_a
  end

  private

  def can_create_hold_for_memember_on_item
    return if item.blank? || member.blank?
    return if item.allow_multiple_holds_per_member? ||
              item.allow_one_holds_per_member? &&
              member.holds.active.where(item: item).count.zero?

    errors.add(:base, :hold_already_exists_for_member_on_item)
  end
end

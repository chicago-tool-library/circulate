class AssignMemberNumbers < ActiveRecord::Migration[6.0]
  class Member < ActiveRecord::Base
    enum status: [:pending, :verified, :suspended, :deactivated], _prefix: true
    scope :verified, -> { where(status: statuses[:verified]) }
    def assign_number
      self.number = (self.class.maximum(:number) || 0) + 1
    end
  end

  def change
    Member.verified.find_each do |member|
      unless member.number
        member.assign_number
        member.save!
      end
    end
  end
end

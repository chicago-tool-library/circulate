# Tells a member that the item we said was ready went to someone else, and
# that they're still first in line for it.
class HoldReturnedToLineJob < ApplicationJob
  def perform(hold_id, appointment_starts_at = nil, appointment_change = nil)
    hold = Hold.find_by(id: hold_id)
    return unless hold

    MemberMailer.with(member: hold.member, hold:, appointment_starts_at:, appointment_change:).hold_returned_to_line.deliver_now
    MemberTexter.new(hold.member).hold_returned_to_line(hold)
  end
end

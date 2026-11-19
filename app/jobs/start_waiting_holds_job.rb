# Starts the next hold in line for one item and notifies the member. The
# scheduled holds:start_waiting_holds task does the same for every item; this
# runs right after an item frees up so the line doesn't wait for it.
class StartWaitingHoldsJob < ApplicationJob
  def perform(item_id)
    item = Item.find_by(id: item_id)
    Hold.start_waiting_holds_and_notify(item:) if item
  end
end

class AddEventIdToHoldRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :hold_requests, :event_id, :string
  end
end

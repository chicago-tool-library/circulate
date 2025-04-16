class DropHoldRequests < ActiveRecord::Migration[6.0]
  def change
    drop_table :hold_request_items # standard:disable Rails/ReversibleMigration
    drop_table :hold_requests # standard:disable Rails/ReversibleMigration
  end
end

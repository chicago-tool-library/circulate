# frozen_string_literal: true

class DropHoldRequests < ActiveRecord::Migration[6.0]
  def change
    drop_table :hold_request_items
    drop_table :hold_requests
  end
end

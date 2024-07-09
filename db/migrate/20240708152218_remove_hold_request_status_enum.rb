class RemoveHoldRequestStatusEnum < ActiveRecord::Migration[7.1]
  def up
    drop_enum :hold_request_status
  end

  def down
    create_enum :hold_request_status, ["new", "completed", "denied"]
  end
end

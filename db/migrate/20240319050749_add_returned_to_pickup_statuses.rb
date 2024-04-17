class AddReturnedToPickupStatuses < ActiveRecord::Migration[7.1]
  def change
    add_enum_value :pickup_status, "returned"
  end
end

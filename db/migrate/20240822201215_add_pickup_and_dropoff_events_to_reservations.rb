class AddPickupAndDropoffEventsToReservations < ActiveRecord::Migration[7.2]
  def change
    change_table(:reservations) do |t|
      t.belongs_to :pickup_event, null: true, foreign_key: {to_table: "events"}
      t.belongs_to :dropoff_event, null: true, foreign_key: {to_table: "events"}
    end
  end
end

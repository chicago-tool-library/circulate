class FlattenPickupIntoReservation < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      # This is destructive, but we don't have any real data yet and this avoids
      # writing a complicated migration to reassociate reservation_loans with reservations
      # instead of pickups.
      direction.up do
        execute "DELETE from reservation_loans"
        execute "DELETE from pickups"
      end
    end
    remove_reference :reservation_loans, :pickup, null: false
    drop_table :pickups do |t|
      t.bigint "creator_id", null: false
      t.enum "status", default: "building", null: false, enum_type: "pickup_status"
      t.bigint "reservation_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "library_id", null: false
      t.index ["creator_id"], name: "index_pickups_on_creator_id"
      t.index ["library_id"], name: "index_pickups_on_library_id"
      t.index ["reservation_id"], name: "index_pickups_on_reservation_id"
    end

    add_reference :reservation_loans, :reservation, null: false

    drop_enum :pickup_status

    %w[obsolete building ready borrowed returned unresolved cancelled].each do |status|
      add_enum_value :reservation_status, status
    end
  end
end

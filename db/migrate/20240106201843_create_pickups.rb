class CreatePickups < ActiveRecord::Migration[7.1]
  def change
    create_enum :pickup_status, [
      "building",
      "ready_for_pickup",
      "picked_up",
      "cancelled"
    ]
    create_table :pickups do |t|
      t.references :creator, null: false, foreign_key: {to_table: "users"}
      t.enum :status, default: "building", null: false, enum_type: "pickup_status"
      t.references :reservation, null: false, foreign_key: true

      t.timestamps
    end
  end
end

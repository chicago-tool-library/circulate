class CreatePendingReservationItems < ActiveRecord::Migration[7.1]
  def change
    create_table :pending_reservation_items do |t|
      t.references :reservable_item, null: false, foreign_key: true, index: {unique: true}
      t.references :reservation, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: {to_table: "users"}

      t.timestamps
    end
  end
end

class AddReviewFieldsToReservation < ActiveRecord::Migration[7.1]
  def change
    create_enum :reservation_status, [
      "pending",
      "requested",
      "approved",
      "rejected"
    ]

    add_column :reservations, :status, :enum, default: "pending", null: "false", enum_type: "reservation_status"
    add_column :reservations, :notes, :string
    add_column :reservations, :reviewed_at, :datetime
    add_reference :reservations, :reviewer, foreign_key: {to_table: "users"}
  end
end

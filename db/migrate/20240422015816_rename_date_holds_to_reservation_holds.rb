class RenameDateHoldsToReservationHolds < ActiveRecord::Migration[7.1]
  def change
    rename_table :date_holds, :reservation_holds
    rename_column :reservation_loans, :date_hold_id, :reservation_hold_id
  end
end

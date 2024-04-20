class AddCheckOutTimesToReservationLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :reservation_loans, :checked_out_at, :timestamp
    add_column :reservation_loans, :checked_in_at, :timestamp
  end
end

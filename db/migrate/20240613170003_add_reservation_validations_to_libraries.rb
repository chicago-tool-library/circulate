class AddReservationValidationsToLibraries < ActiveRecord::Migration[7.1]
  def change
    add_column :libraries, :maximum_reservation_length, :integer, null: false, default: 21
    add_column :libraries, :minimum_reservation_start_distance, :integer, null: false, default: 2
    add_column :libraries, :maximum_reservation_start_distance, :integer, null: false, default: 90
  end
end

class AddDatesToReservationHolds < ActiveRecord::Migration[7.2]
  class MigrationReservations < ApplicationRecord
    self.table_name = "reservations"
    has_many :reservation_holds, class_name: "MigrationReservationHold", foreign_key: "reservation_id"
  end

  class MigrationReservationHold < ApplicationRecord
    self.table_name = "reservation_holds"
  end

  def up
    add_column :reservation_holds, :started_at, :datetime
    add_column :reservation_holds, :ended_at, :datetime

    Reservation.find_each do |reservation|
      reservation.reservation_holds.update_all(started_at: reservation.started_at, ended_at: reservation.ended_at)
    end

    change_column_null :reservation_holds, :started_at, true
    change_column_null :reservation_holds, :ended_at, true
  end

  def down
    remove_column :reservation_holds, :started_at
    remove_column :reservation_holds, :ended_at
  end
end

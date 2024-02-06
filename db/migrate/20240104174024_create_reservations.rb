class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.string :name
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end

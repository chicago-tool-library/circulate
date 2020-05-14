class AddReservationCounterCacheToItem < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :reservations_count, :integer, default: 0, null: false
  end
end

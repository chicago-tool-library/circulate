class ReplaceDateHoldReservableItemIdWithItemPoolId < ActiveRecord::Migration[7.1]
  def change
    remove_reference :date_holds, :reservable_item
    add_reference :date_holds, :item_pool, null: false, foreign_key: true
  end
end

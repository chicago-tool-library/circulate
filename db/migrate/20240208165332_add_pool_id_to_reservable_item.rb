class AddPoolIdToReservableItem < ActiveRecord::Migration[7.1]
  def change
    add_reference :reservable_items, :item_pool, null: false, foreign_key: true
  end
end

class ScopeGroupModelsToLibraries < ActiveRecord::Migration[7.1]
  def change
    add_reference :item_pools, :library, null: false, foreign_key: true
    add_reference :reservable_items, :library, null: false, foreign_key: true
    add_reference :date_holds, :library, null: false, foreign_key: true
    add_reference :reservations, :library, null: false, foreign_key: true
    add_reference :pickups, :library, null: false, foreign_key: true
  end
end

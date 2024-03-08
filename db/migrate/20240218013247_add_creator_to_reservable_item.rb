class AddCreatorToReservableItem < ActiveRecord::Migration[7.1]
  def change
    add_reference :reservable_items, :creator, null: false, foreign_key: {to_table: "users"}
  end
end

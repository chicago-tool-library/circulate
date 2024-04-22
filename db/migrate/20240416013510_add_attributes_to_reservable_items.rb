class AddAttributesToReservableItems < ActiveRecord::Migration[7.1]
  def change
    add_column :reservable_items, :status, :enum, enum_type: "item_status"
    add_column :reservable_items, :brand, :string
    add_column :reservable_items, :model, :string
    add_column :reservable_items, :serial, :string
    add_column :reservable_items, :number, :integer
    add_column :reservable_items, :purchase_price_cents, :integer
    reversible do |direction|
      direction.up { execute "UPDATE reservable_items SET number=id" }
    end
    change_column_null :reservable_items, :number, false
    add_index :reservable_items, ["number", "library_id"], unique: true
  end
end

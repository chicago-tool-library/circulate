class CreateWishListItems < ActiveRecord::Migration[8.0]
  def change
    create_table :wish_list_items do |t|
      t.belongs_to :item, null: false, foreign_key: true
      t.belongs_to :member, null: false, foreign_key: true
      t.index [:item_id, :member_id], unique: true

      t.timestamps
    end
  end
end

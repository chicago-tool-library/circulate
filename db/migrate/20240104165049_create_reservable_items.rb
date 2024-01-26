class CreateReservableItems < ActiveRecord::Migration[7.1]
  def change
    create_table :reservable_items do |t|
      t.string :name

      t.timestamps
    end
  end
end

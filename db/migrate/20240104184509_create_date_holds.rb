class CreateDateHolds < ActiveRecord::Migration[7.1]
  def change
    create_table :date_holds do |t|
      t.references :reservation, null: false
      t.references :reservable_item, null: false
      t.timestamps
    end
  end
end

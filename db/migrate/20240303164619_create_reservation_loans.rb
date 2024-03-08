class CreateReservationLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :reservation_loans do |t|
      t.references :pickup, null: false, foreign_key: true
      t.references :date_hold, null: false, foreign_key: true
      t.references :reservable_item, foreign_key: true
      t.integer :quantity, comment: "For item pools without uniquely numbered items"

      t.timestamps
    end
  end
end

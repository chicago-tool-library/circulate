class CreateBorrowPolicies < ActiveRecord::Migration[6.0]
  def change
    create_table :borrow_policies do |t|
      t.string :name, null: false, unique: true
      t.integer :duration, null: false, default: 7
      t.monetize :fine, null: false, default: 0
      t.integer :fine_period, null: false, default: 1

      t.timestamps
    end
  end
end

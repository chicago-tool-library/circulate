class AddQuantityToDateHold < ActiveRecord::Migration[7.1]
  def change
    add_column :date_holds, :quantity, :integer, null: false, default: 1
  end
end

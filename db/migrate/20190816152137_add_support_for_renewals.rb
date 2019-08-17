class AddSupportForRenewals < ActiveRecord::Migration[6.0]
  def change
    add_column :loans, :renewal_count, :integer, default: 0, null: false
    add_reference :loans, :initial_loan, foreign_key: {to_table: :loans}
  end
end

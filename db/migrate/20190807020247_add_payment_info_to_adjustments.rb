class AddPaymentInfoToAdjustments < ActiveRecord::Migration[6.0]
  def change
    create_enum :adjustment_source, ["cash", "square"]

    change_table :adjustments do |t|
      t.enum :payment_source, enum_type: :adjustment_source
      t.column :square_transaction_id, :string
      t.change :adjustable_type, :string, null: true # standard:disable Rails/ReversibleMigration
      t.change :adjustable_id, :bigint, null: true # standard:disable Rails/ReversibleMigration
      t.remove :kind # standard:disable Rails/ReversibleMigration
    end
  end
end

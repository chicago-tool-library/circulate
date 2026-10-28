class AddUsageFeesToItemPools < ActiveRecord::Migration[8.0]
  def change
    add_column :item_pools, :usage_fee_cents, :integer, default: 0, null: false
    add_column :item_pools, :usage_fee_currency, :string, default: "USD", null: false
    add_column :item_pools, :periodic_fee_cents, :integer, default: 0, null: false
    add_column :item_pools, :periodic_fee_currency, :string, default: "USD", null: false
    add_column :item_pools, :periodic_fee_period, :integer, default: 1, null: false
  end
end

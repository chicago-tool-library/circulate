class AddPurchasePriceAndPurchaseLinkToItem < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :purchase_link, :string
    add_column :items, :purchase_price_cents, :integer
  end
end

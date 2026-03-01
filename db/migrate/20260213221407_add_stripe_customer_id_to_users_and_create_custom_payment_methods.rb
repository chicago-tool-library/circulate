class AddStripeCustomerIdToUsersAndCreateCustomPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_customer_id, :string
    add_index :users, :stripe_customer_id

    create_enum :payment_method_status, [:active, :expired, :detached]
    create_table :payment_methods do |t|
      t.belongs_to :user, null: false
      t.string :stripe_id, null: false
      t.string :display_brand, null: false
      t.string :last_four, null: false
      t.integer :expire_month, null: false
      t.integer :expire_year, null: false
      t.enum :status, enum_type: :payment_method_status, default: "active", null: false
      t.timestamps

      t.index :stripe_id, unique: true
    end
  end
end

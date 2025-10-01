class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_enum :payment_method_status, [:active, :expired, :detached]
    create_table :payment_methods do |t|
      t.belongs_to :user
      t.string :stripe_id
      t.string :display_brand
      t.string :last_four
      t.integer :expire_month
      t.integer :expire_year
      t.enum :status, enum_type: :payment_method_status, default: "active", null: false
      t.timestamps

      t.index :stripe_id, unique: true
    end
  end
end

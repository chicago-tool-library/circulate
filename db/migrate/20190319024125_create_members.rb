class CreateMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :members do |t|
      t.string :full_name, null: false
      t.string :preferred_name
      t.string :email, null: false
      t.string :phone_number, null: false
      t.integer :pronoun
      t.string :custom_pronoun
      t.text :notes
      t.integer :id_kind
      t.string :other_id_kind
      t.string :id_number
      t.boolean :address_verified

      t.timestamps
    end
  end
end

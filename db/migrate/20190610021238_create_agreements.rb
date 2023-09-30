# frozen_string_literal: true

class CreateAgreements < ActiveRecord::Migration[6.0]
  def change
    create_table :agreements do |t|
      t.string :name, null: false
      t.string :summary
      t.text :body
      t.integer :position, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end

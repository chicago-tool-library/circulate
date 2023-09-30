# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :description
      t.string :size
      t.string :brand
      t.string :model
      t.string :serial

      t.timestamps
    end
  end
end

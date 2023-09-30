# frozen_string_literal: true

class CreateHolds < ActiveRecord::Migration[6.0]
  def change
    create_table :holds do |t|
      t.references :member, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

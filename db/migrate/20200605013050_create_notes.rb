class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.references :notable, null: false, polymorphic: true
      t.references :creator, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end

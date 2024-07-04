class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers do |t|
      t.belongs_to :stem, null: false, foreign_key: true
      t.belongs_to :reservation, null: false, foreign_key: true
      t.jsonb :result, null: false, default: {}

      t.timestamps
      t.index [:stem_id, :reservation_id], unique: true
    end
  end
end

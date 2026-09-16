class CreateQuizQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_questions do |t|
      t.references :library, null: false, foreign_key: true
      t.text :content, null: false
      t.text :explanation
      t.integer :position, null: false, default: 0
      t.datetime :archived_at

      t.timestamps
    end

    create_table :quiz_choices do |t|
      t.references :quiz_question, null: false, foreign_key: true
      t.text :content, null: false
      t.boolean :correct, null: false, default: false
      t.integer :position, null: false, default: 0
      t.integer :times_chosen, null: false, default: 0

      t.timestamps
    end
  end
end

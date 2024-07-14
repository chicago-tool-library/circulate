class CreateStems < ActiveRecord::Migration[7.1]
  def change
    create_enum :answer_type, ["text", "integer"]

    create_table :stems do |t|
      t.belongs_to :question, null: false, foreign_key: true
      t.text :content, null: false
      t.enum :answer_type, enum_type: "answer_type", null: false, default: "text"

      t.timestamps
    end
  end
end

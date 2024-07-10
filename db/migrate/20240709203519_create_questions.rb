class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.string :name, null: false, index: {unique: true}
      t.datetime :archived_at
      t.belongs_to :library, null: false
      t.timestamps
    end
  end
end

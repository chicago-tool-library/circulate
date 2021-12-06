class CreateLibraryUpdates < ActiveRecord::Migration[6.1]
  def change
    create_table :library_updates do |t|
      t.string :title
      t.boolean :published
      t.references :library

      t.timestamps
    end

    add_index :library_updates, [:library_id, :published]
  end
end

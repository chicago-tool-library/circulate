class AddPinnedToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :pinned, :boolean
  end
end

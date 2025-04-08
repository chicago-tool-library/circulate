class AddUniquelyNumberedToLoans < ActiveRecord::Migration[6.0]
  def change
    add_column :loans, :uniquely_numbered, :boolean, default: true, null: false
    change_column_default :loans, :uniquely_numbered, nil # standard:disable Rails/ReversibleMigration
    remove_index :loans, name: "index_active_loans_on_item_id" # standard:disable Rails/ReversibleMigration
    add_index :loans, :item_id, unique: true, where: "ended_at IS NULL AND uniquely_numbered = true", name: "index_active_numbered_loans_on_item_id"
  end
end

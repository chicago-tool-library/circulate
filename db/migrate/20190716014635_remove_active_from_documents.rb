class RemoveActiveFromDocuments < ActiveRecord::Migration[6.0]
  def change
    remove_column :documents, :active # standard:disable Rails/ReversibleMigration
  end
end

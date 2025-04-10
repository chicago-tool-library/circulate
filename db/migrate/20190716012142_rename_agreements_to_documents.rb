class RenameAgreementsToDocuments < ActiveRecord::Migration[6.0]
  def change
    rename_table :agreements, :documents
    add_column :documents, :code, :string
    remove_column :documents, :position # standard:disable Rails/ReversibleMigration
    remove_column :documents, :body # standard:disable Rails/ReversibleMigration
  end
end

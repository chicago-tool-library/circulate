class DropOrganizationWebsiteUniquenessIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :organizations, [:library_id, :website], unique: true
  end
end

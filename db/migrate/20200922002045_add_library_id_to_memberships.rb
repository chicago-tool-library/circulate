class AddLibraryIdToMemberships < ActiveRecord::Migration[6.0]
  def change
    add_column :memberships, :library_id, :integer
  end
end

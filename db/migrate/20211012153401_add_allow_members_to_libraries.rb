class AddAllowMembersToLibraries < ActiveRecord::Migration[6.0]
  def change
    add_column :libraries, :allow_members, :boolean, default: true, after: :address, null: false
  end
end

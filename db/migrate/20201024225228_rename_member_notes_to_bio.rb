class RenameMemberNotesToBio < ActiveRecord::Migration[6.0]
  def change
    rename_column :members, :notes, :bio
  end
end

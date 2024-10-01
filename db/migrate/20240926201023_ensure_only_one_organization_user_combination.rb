class EnsureOnlyOneOrganizationUserCombination < ActiveRecord::Migration[7.2]
  def change
    add_index :organization_members, %i[organization_id user_id], unique: true
  end
end

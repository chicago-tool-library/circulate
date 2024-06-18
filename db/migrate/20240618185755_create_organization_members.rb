class CreateOrganizationMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :organization_members do |t|
      t.text :full_name
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CleanupOrganizations < ActiveRecord::Migration[8.0]
  def change
    drop_table :organization_members do |t|
      t.string :full_name
      t.belongs_to :organization, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.timestamps
    end

    drop_table :organizations do |t|
      t.string :name, null: false
      t.string :website
      t.belongs_to :library, null: false, foreign_key: true
      t.timestamps
    end

    drop_enum :organization_member_role
  end
end

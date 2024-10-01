class AddRoleToOrganizationMembers < ActiveRecord::Migration[7.2]
  def change
    create_enum :organization_member_role, %w[
      admin
      member
    ]

    change_table :organization_members do |t|
      t.enum :role, default: "member", null: false, enum_type: :organization_member_role
    end
  end
end

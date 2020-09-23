class AddSuperAdminToRoleEnum < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_enum_value :user_role, "super_admin"
  end
end

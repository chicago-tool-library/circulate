# frozen_string_literal: true

class AddMemberToRoleEnum < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_enum_value :user_role, "member"
  end
end

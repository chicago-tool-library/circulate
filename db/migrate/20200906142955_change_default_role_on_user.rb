# frozen_string_literal: true

class ChangeDefaultRoleOnUser < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :role, from: "staff", to: "member"
  end
end

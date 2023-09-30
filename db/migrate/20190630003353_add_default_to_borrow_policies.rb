# frozen_string_literal: true

class AddDefaultToBorrowPolicies < ActiveRecord::Migration[6.0]
  def change
    add_column :borrow_policies, :default, :boolean, default: false, null: false
  end
end

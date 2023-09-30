# frozen_string_literal: true

class AddUniquelyNumberedToBorrowPolicies < ActiveRecord::Migration[6.0]
  def change
    add_column :borrow_policies, :uniquely_numbered, :boolean, default: true, null: false
  end
end

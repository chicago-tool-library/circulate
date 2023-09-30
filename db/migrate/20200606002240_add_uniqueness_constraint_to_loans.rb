# frozen_string_literal: true

class AddUniquenessConstraintToLoans < ActiveRecord::Migration[6.0]
  def change
    add_index :loans, [:initial_loan_id, :renewal_count], unique: true
  end
end

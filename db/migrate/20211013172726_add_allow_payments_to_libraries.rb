# frozen_string_literal: true

class AddAllowPaymentsToLibraries < ActiveRecord::Migration[6.0]
  def change
    add_column :libraries, :allow_payments, :boolean, default: true, after: :allow_payments, null: false
  end
end

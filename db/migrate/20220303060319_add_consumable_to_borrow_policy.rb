# frozen_string_literal: true

class AddConsumableToBorrowPolicy < ActiveRecord::Migration[6.1]
  def change
    add_column :borrow_policies, :consumable, :boolean, default: false
  end
end

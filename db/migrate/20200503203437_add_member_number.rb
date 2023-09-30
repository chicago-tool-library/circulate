# frozen_string_literal: true

class AddMemberNumber < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :number, :integer
    add_index :members, :number, unique: true
  end
end

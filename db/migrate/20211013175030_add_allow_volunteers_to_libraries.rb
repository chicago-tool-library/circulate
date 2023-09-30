# frozen_string_literal: true

class AddAllowVolunteersToLibraries < ActiveRecord::Migration[6.1]
  def change
    add_column :libraries, :allow_volunteers, :boolean, default: true, after: :address, null: false
  end
end

# frozen_string_literal: true

class AddAddressFieldsToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :address1, :string
    add_column :members, :address2, :string
    add_column :members, :city, :string
    add_column :members, :region, :string
  end
end

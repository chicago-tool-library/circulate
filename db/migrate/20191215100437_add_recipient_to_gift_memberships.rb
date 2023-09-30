# frozen_string_literal: true

class AddRecipientToGiftMemberships < ActiveRecord::Migration[6.0]
  def change
    add_column :gift_memberships, :recipient_name, :string
  end
end

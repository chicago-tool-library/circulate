# frozen_string_literal: true

class AddCommunicationFieldsToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :reminders_via_email, :boolean, default: false, null: false
    add_column :members, :reminders_via_text, :boolean, default: false, null: false
    add_column :members, :receive_newsletter, :boolean, default: false, null: false
    add_column :members, :volunteer_interest, :boolean, default: false, null: false
    add_column :members, :desires, :string
  end
end

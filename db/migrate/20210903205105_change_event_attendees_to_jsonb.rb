# frozen_string_literal: true

class ChangeEventAttendeesToJsonb < ActiveRecord::Migration[6.1]
  def change
    remove_column :events, :attendees
    add_column :events, :attendees, :jsonb
  end
end

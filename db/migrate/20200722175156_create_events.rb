# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :calendar_id, null: false
      t.string :calendar_event_id, null: false
      t.timestamp :start, null: false
      t.timestamp :finish, null: false
      t.string :summary
      t.string :description
      t.json :attendees, default: {}

      t.timestamps
      t.index [:calendar_id, :calendar_event_id], unique: true
    end
  end
end

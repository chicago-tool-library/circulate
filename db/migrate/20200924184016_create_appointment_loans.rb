# frozen_string_literal: true

class CreateAppointmentLoans < ActiveRecord::Migration[6.0]
  def change
    create_table :appointment_loans do |t|
      t.belongs_to :appointment
      t.belongs_to :loan

      t.timestamps
    end
  end
end

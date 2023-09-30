# frozen_string_literal: true

class CreateAppointmentHolds < ActiveRecord::Migration[6.0]
  def change
    create_table :appointment_holds do |t|
      t.belongs_to :appointment
      t.belongs_to :hold

      t.timestamps
    end
  end
end

class CreateAppointments < ActiveRecord::Migration[6.0]
  def change
    create_table :appointments do |t|
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.text :comment, null: false, default: ""
      t.belongs_to :member

      t.timestamps
    end
  end
end

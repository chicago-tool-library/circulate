class AddSubmittedByToReservations < ActiveRecord::Migration[7.1]
  def change
    change_table(:reservations) do |t|
      t.belongs_to :submitted_by, null: false, foreign_key: {to_table: "users"}
    end
  end
end

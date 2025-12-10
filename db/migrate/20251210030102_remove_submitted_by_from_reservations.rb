class RemoveSubmittedByFromReservations < ActiveRecord::Migration[8.0]
  def change
    remove_column :reservations, :submitted_by_id, type: :integer
  end
end

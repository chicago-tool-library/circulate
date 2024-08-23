class ChangeReservationSubmittedByFromUserToMember < ActiveRecord::Migration[7.2]
  def change
    remove_belongs_to(:reservations, :submitted_by, foreign_key: {to_table: "users"})
    add_belongs_to :reservations, :submitted_by, null: false, foreign_key: {to_table: "members"}
  end
end

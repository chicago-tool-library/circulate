class AssociateReservationsWithOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_reference :reservations, :organization, null: false
  end
end

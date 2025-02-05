class ModifyReservationLoansQuantity < ActiveRecord::Migration[7.2]
  def change
    change_column_null :reservation_loans, :quantity, false, 1
    change_column_default :reservation_loans, :quantity, from: nil, to: 1
    change_column_comment :reservation_loans, :quantity, from: "For item pools without uniquely numbered items", to: ""
  end
end

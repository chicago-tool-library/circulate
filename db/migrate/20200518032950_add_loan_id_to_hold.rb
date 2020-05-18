class AddLoanIdToHold < ActiveRecord::Migration[6.0]
  def change
    add_reference :holds, :loan, foreign_key: true
  end
end

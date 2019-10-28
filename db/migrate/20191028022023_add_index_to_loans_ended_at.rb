class AddIndexToLoansEndedAt < ActiveRecord::Migration[6.0]
  def change
    add_index :loans, :ended_at
  end
end

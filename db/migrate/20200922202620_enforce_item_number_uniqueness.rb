class EnforceItemNumberUniqueness < ActiveRecord::Migration[6.0]
  def change
    add_index :items, [:number, :library_id], unique: true
  end
end

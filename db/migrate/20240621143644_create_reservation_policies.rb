class CreateReservationPolicies < ActiveRecord::Migration[7.1]
  def change
    create_table :reservation_policies do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :default, null: false, default: false
      t.integer :maximum_duration, null: false, default: 21
      t.integer :minimum_start_distance, null: false, default: 2
      t.integer :maximum_start_distance, null: false, default: 90
      t.belongs_to :library, null: false
      t.timestamps
      t.index [:library_id, :name], unique: true
    end

    change_table(:item_pools) do |t|
      t.belongs_to :reservation_policy
    end
  end
end

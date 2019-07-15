class CreateMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :memberships do |t|
      t.references :member, null: false, foreign_key: true
      t.datetime :started_on, null: false, precision: 6
      t.datetime :ended_on, precision: 6

      t.timestamps
    end
  end
end

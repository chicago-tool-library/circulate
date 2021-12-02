class CreateHoldRequests < ActiveRecord::Migration[6.0]
  def change
    create_enum :hold_request_status, [
      "new",
      "completed",
      "denied"
    ]

    create_table :hold_requests do |t|
      t.string :member_number
      t.string :email
      t.references :member
      t.string :notes
      t.enum :status, enum_name: :hold_request_status, null: false, default: "new"
      t.timestamps
    end
  end
end

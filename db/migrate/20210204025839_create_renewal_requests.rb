class CreateRenewalRequests < ActiveRecord::Migration[6.0]
  def change
    create_enum :renewal_request_status, ["requested", "approved", "rejected"]

    create_table :renewal_requests do |t|
      t.enum :status, enum_name: :renewal_request_status, null: false, default: "requested"
      t.belongs_to :loan, foreign_key: true
      t.timestamps
    end
  end
end

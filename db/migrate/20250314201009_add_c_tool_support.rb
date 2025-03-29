class AddCToolSupport < ActiveRecord::Migration[7.2]
  def change
    add_column :borrow_policies, :requires_approval, :boolean, null: false, default: false

    create_enum :borrow_policy_approval_status, %w[
      approved
      rejected
      requested
      revoked
    ], force: :cascade

    create_table :borrow_policy_approvals do |t|
      t.belongs_to :borrow_policy, null: false, foreign_key: true, index: true
      t.belongs_to :member, null: false, foreign_key: true, index: true
      t.index %i[borrow_policy_id member_id], unique: true

      t.enum :status, enum_type: :borrow_policy_approval_status, null: false, index: true, default: "requested"

      t.text :status_reason

      t.timestamps
    end
  end
end

class AddMembershipTypeToMembership < ActiveRecord::Migration[7.1]
  def change
    create_enum :membership_type, ["initial", "renewal"]
    add_column :memberships, :membership_type, :enum, null: false, enum_type: "membership_type", default: "initial"
  end
end
